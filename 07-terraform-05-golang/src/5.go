package main

import "fmt"

func main() {
	for i := 1; i < 100+1; i++ {
		//fmt.Println(i)
		if i%3 == 0 {
			fmt.Println(i)
		}
		//fmt.Println(i)
	}

}

// OUTPUT
// 3
// 6
// 9
// 12
//
// 15
// 18
// 21
// 24
// 27
// 30
// 33
// 36
// 39
// 42
// 45
// 48
// 51
// 54
// 57
// 60
// 63
// 66
// 69
// 72
// 75
// 78
// 81
// 84
// 87
// 90
// 93
// 96
// 99
//
// Program exited.