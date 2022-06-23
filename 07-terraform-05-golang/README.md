# Домашнее задание к занятию "7.5. Основы golang"

---

В данном файле приведены **только ответы** ! Т.е. можно искать по **Ответ:**

Решал в песочнице [https://play.golang.org/](https://play.golang.org/) и в IDE.

---


С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  


## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

3. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:

**Ответ:**  [3](https://github.com/bolgovsky/virt-homeworks/blob/master/07-terraform-05-golang/src/3/3.go)
```bash
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

Enter a number: 42.650918635170605

Program exited.
```
 
4. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:

**Ответ:** [4](https://github.com/bolgovsky/virt-homeworks/blob/master/07-terraform-05-golang/src/main/main.go)
```bash
package main

import "fmt"

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	length := len(x)
	//fmt.Println(length)
	min := x[0]
	for i := 0; i < length; i++ {
		if x[i] < min {
			min = x[i]
		}

		//fmt.Println(x[i])
	}
	fmt.Println(min)
}

9

Program exited.
```

5. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

**Ответ:**  [5](https://github.com/bolgovsky/virt-homeworks/blob/master/07-terraform-05-golang/src/5/5.go)
```bash
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

3
6
9
12
15
18
21
24
27
30
33
36
39
42
45
48
51
54
57
60
63
66
69
72
75
78
81
84
87
90
93
96
99

Program exited.
```

В виде решения ссылку на код или сам код. 

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

**Ответ:** Сделал два файла, инициализировал puppy(?![хоть бы кто упомянул про это!])

main.go
```bash
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
```

main_test.go
```bash
package main

import (
       "testing"
)


func testMin(t *testing.T) {
    //test:=[]int{0,1}
    check := IntMin(([]int{0,1}))
    if check != 0 {
        t.Errorf("Error in calculation: min can not be %d", check)
    }
}
```

Вывод:

```bash 

C:\Users\Денис\PycharmProjects\virt-homeworks\07-terraform-05-golang\src\main>go mod init puppy
go: creating new go.mod: module puppy
go: to add module requirements and sums:
        go mod tidy

C:\Users\Денис\PycharmProjects\virt-homeworks\07-terraform-05-golang\src\main>go test
testing: warning: no tests to run
PASS
ok      puppy   0.035s

```