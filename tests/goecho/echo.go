// Echo1 prints its command-line arguments.
package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	for i := 1; i < len(os.Args); i++ {
		// STDOUT
		fmt.Printf("STDOUT: Arg is %d is <%s>\n", i, os.Args[i])
		// STDERR
		fmt.Fprintf(os.Stderr, "STDERR: Arg is %d is <%s>\n", i, os.Args[i])
		// delay
		time.Sleep(300 * time.Millisecond)
	}
}
