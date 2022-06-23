package main

import "fmt"

func main() {
	fmt.Print("Enter a number: ")
	var input float64
	input = 13
	fmt.Scanf("%f", &input)
	output := input / 0.3048
	fmt.Println(output)
}

// OUTPUT
// go run 2.go
// Enter a number: 12
// 39.37007874015748
