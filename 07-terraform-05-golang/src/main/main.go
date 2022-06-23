package main

import ("fmt"
       //"testing"
)

func main() {
    y:= []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	fmt.Println(IntMin(y))
}

func IntMin(x[]int) int{
	//x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	length := len(x)
	//fmt.Println(length)
	min := x[0]
	for i := 0; i < length; i++ {
		if x[i] < min {
			min = x[i]
		}
		//fmt.Println(x[i])
	}
	return min
}
