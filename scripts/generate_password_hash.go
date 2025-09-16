package main

import (
	"fmt"
	"os"

	"golang.org/x/crypto/bcrypt"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run generate_password_hash.go <password>")
		fmt.Println("Example: go run generate_password_hash.go mypassword123")
		os.Exit(1)
	}

	password := os.Args[1]

	// Use bcrypt cost 12 (same as application default)
	cost := 12

	hash, err := bcrypt.GenerateFromPassword([]byte(password), cost)
	if err != nil {
		fmt.Printf("Error generating hash: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Password: %s\n", password)
	fmt.Printf("Bcrypt Hash (cost %d): %s\n", cost, string(hash))

	// Verify the hash works
	err = bcrypt.CompareHashAndPassword(hash, []byte(password))
	if err != nil {
		fmt.Printf("Warning: Hash verification failed: %v\n", err)
	} else {
		fmt.Println("✓ Hash verification successful")
	}
}
