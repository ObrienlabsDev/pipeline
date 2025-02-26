package main

import (
    "fmt"
    "log"
    "os"
    "os/exec"
    "path/filepath"
    "sync"
)

func main() {
    // 1. List all entries in current directory
    entries, err := os.ReadDir(".")
    if err != nil {
        log.Fatalf("Failed to list current directory: %v", err)
    }

    // Prepare concurrency limiting
    const maxConcurrent = 4
    sem := make(chan struct{}, maxConcurrent)  // semaphore to limit goroutines
    var wg sync.WaitGroup

    // 2. Iterate through entries and handle directories
    for _, entry := range entries {
        if !entry.IsDir() {
            continue // skip files, only interested in directories
        }
        dirName := entry.Name()

        // 2. Check if directory is a Git repo (contains .git)
        gitPath := filepath.Join(dirName, ".git")
        info, err := os.Stat(gitPath)
        if err != nil || !info.IsDir() {
            // Not a Git repository, log and skip
            if os.IsNotExist(err) {
                log.Printf("Skipping %s: not a Git repository", dirName)
            } else {
                log.Printf("Skipping %s: cannot access .git folder (%v)", dirName, err)
            }
            continue
        }

        // 3. & 4. Use a goroutine to run `git pull` (concurrently, with limit)
        wg.Add(1)
        sem <- struct{}{}          // acquire a slot (blocks if maxConcurrent reached)
        go func(repo string) {
            defer wg.Done()
            defer func() { <-sem }()  // release the slot when done

            // 3. Execute git pull --recurse-submodules
            cmd := exec.Command("git", "pull", "--recurse-submodules")
            cmd.Dir = repo  // set working directory to the repo
            output, err := cmd.CombinedOutput()
            if err != nil {
                // 5. Log error if command fails
                log.Printf("Failed to update %s: %v\nOutput: %s", repo, err, output)
            } else {
                // Log/print success message
                fmt.Printf("Updated %s successfully\n", repo)
            }
        }(dirName)
    }

    // 4. Wait for all goroutines to finish
    wg.Wait()
}

