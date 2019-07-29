//2.-1正常引用
//class Person {
//    let name: String
//    init(name: String) {
//        self.name = name
//        print("\(name)正在被初始化")
//    }
//    deinit {
//        print("\(name)即将被销毁")          // person3 = nil时打印
//    }
//}
//var person1: Person?                      // 可选类型的变量,方便置空
//var person2: Person?
//var person3: Person?
//person1 = Person(name: "Dariel")          //创建Person实例并与person1建立了强引用
//person2 = person1                         // 只要有一个强引用在,实例就能不被销毁
//person3 = person1                         // 目前该实例共有三个强引用
//
//person1 = nil
//print(person1?.name,person2?.name,person3?.name)
//person2 = nil                             // 因为还有一个强引用,实例不会被销毁
//print(person1?.name,person2?.name,person3?.name)
//person3 = nil                             // 最后一个强引用被断开,ARC会销毁该实例
//print(person1?.name,person2?.name,person3?.name)



//2.0.MARK:-双强引用
/////////
//class People {
//    let name: String
//    init(name: String) { self.name = name }
//    var apartment: Apartment?              // 人住的公寓属性
//    deinit {
//        print("People被销毁")
//    }
//}
//
//class Apartment {
//    let unit: String
//    init(unit: String) { self.unit = unit }
//    var tenant: People?                   // 公寓中的人的属性
//    deinit {
//        print("Apartment被销毁")
//    }
//}
//
//var people1: People? = People(name: "Dariel")  // 定义两个实例变量
//var apartment1: Apartment? = Apartment(unit: "4A")
//
//people1!.apartment = apartment1           // 两者相互引用
//apartment1?.tenant = people1              // 而且彼此都是强引用
//
//people1 = nil
//apartment1 = nil                          // 两个引用都置为nil了,但实例并没有销毁

//print(people1?.name,apartment1?.unit,people1?.apartment?.unit,apartment1?.tenant?.name)

///////////////////

//2.1.weak 弱引用
//如果产生循环引用的两个属性都允许为nil,这种情况适合用弱引用来解决

//class OtherPeople {
//    let name: String
//    init(name: String) { self.name = name }
//    var apartment: OtherApartment?        // 人住的公寓属性
//    deinit { print("\(name)被销毁") }
//}
//
//class OtherApartment {
//    let unit: String
//    init(unit: String) { self.unit = unit }
//    weak var tenant: OtherPeople?         // 加一个weak关键字,表示该变量为弱引用
//    deinit { print("\(unit)被销毁") }
//}
//
//var otherPeople1: OtherPeople? = OtherPeople(name: "Dariel") // 定义两个实例变量
//var otherApartment1: OtherApartment? = OtherApartment(unit: "4A")
//
//otherPeople1!.apartment = otherApartment1 // 两者相互引用
//otherApartment1?.tenant = otherPeople1    // 但tenant是弱引用
////otherPeople1 = nil
//otherApartment1 = nil                     // 实例被销毁,deinit中都会打印销毁的信息
//
//print(otherPeople1?.name,otherApartment1?.unit,otherPeople1?.apartment?.unit,otherApartment1?.tenant?.name)
////////////////

//2.2.如果产生循环引用的两个属性一个允许为nil,另一个不允许为nil,这种情况适合用无主引用来解决
//unowned 无主引用
//class Dog {
//    let name: String
//    var food: Food?
//    init(name: String) {
//        self.name = name
//    }
//    deinit { print("\(name)被销毁") }
//}
//class Food {
//    let number: Int
//    unowned var owner: Dog               // owner是一个无主引用
//    init(number: Int, owner: Dog) {
//        self.number = number
//        self.owner = owner
//    }
//    deinit { print("食物被销毁") }
//}
//
//var dog1: Dog? = Dog(name: "Kate")
//var food: Food? = Food.init(number: 6, owner: dog1!)
//dog1?.food = food // dog强引用food,而food对dog是无主引用
//food = nil
//dog1 = nil
//  // 这样就可以同时销毁两个实例了
////print(food?.number,food?.owner)


///////////////////
//2.3.如果产生循环引用的两个属性都必须有值,不能为nil,这种情况适合一个类使用无主属性,另一个类使用隐式解析可选类型

//class Country {
//    let name: String
//    var capitalCity: City!                // 初始化完成后可以当非可选类型使用
//    init(name: String, capitalName: String) {
//        self.name = name
//        self.capitalCity = City(name: capitalName, country: self)
//    }
//    deinit { print("Country实例被销毁") }
//}
//
//class City {
//    let name: String
//    unowned let country: Country
//    init(name: String, country: Country) {
//        self.name = name
//        self.country = country
//    }
//    deinit { print("City实例被销毁") }
//}
//
//// 这样一条语句就能够创建两个实例
//var country: Country? = Country(name: "China", capitalName: "HangZhou")
//print(country!.name)                        // China
//print(country!.capitalCity.name)            // HangZhou
//country = nil                               // 同时销毁两个实例


///////////////////
//2.4闭包

class Element {
    let name: String
    let text: String?
    
    lazy var group:() -> String = {        // 相当于一个没有参数返回string的函数
        [unowned self] in                   // 定义捕获列表,将self变为无主引用
        if let text = self.text {           // 解包
            return "\(self.name), \(text)"
        }else {
            return "\(self.name)"
        }
    }
    
    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }
    deinit { print("\(name)被销毁") }
}

var element1: Element? = Element(name: "Alex", text: "Hello")
print(element1!.group())                     // Alex, Hello,闭包与实例相互引用

element1 = nil                               // self为无主引用,实例能被销毁
