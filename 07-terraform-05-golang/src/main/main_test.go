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
