import UIKit


// buat fungsi untuk bertukar nilai antara dua bilangan
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let tempInt: Int = a
    a = b
    b = tempInt
}
var intA = 3
var intB = 7
print("intA =",intA,"intB =",intB)  // mencetak intA = 3 intB = 7
// tukar nilai dua penyimpan bilangan
swapTwoInts(&intA, &intB)
print("intA =",intA,"intB =",intB)  // mencetak intA = 7 intB = 3



