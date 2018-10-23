# iFS
Development facilities for iOS 9+ to support developer in speeding up certain operations that can be used frequently
 
 ## InApp purchase verify
 ```
FsManager.InAppPurchase.shared.verifyReceipt(productID: "ProductID001", sharedKey: "XXX", isSandBox: true) { (jResult) in
	print("Output: \(jResult)")
}
```
The verification involves the use of the product ID and the shared key. The possible answers can be:
 * VALID (Product purchased)
 * NOTEST (It is not possible to carry out a test or have never been made purchases)
 * EXPIRE (Expired, in case of renewable subscription)
 * CANCEL (Canceled for a refund request)

## SideMenu
```
let sideMenuVC = sideMenuViewController() 
if self.navigationController != nil {
	iFS.SideMenu.open(direction: .left, container: self.navigationController!, injectViewController: sideMenuVC)
}
```

## Parsing JSON to codable model
```
extension iFS.Models {

    class Base: Codable {
        let update: Bool
        let success: Bool
        
        private enum CodingKeys: String, CodingKey {
            case update
            case success
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.update = try container.decode(Bool.self, forKey: .update)
            self.success = try container.decode(Bool.self, forKey: .success)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(update, forKey: .update)
            try container.encode(success, forKey: .success)
        }
    }
    
    class User: Base {
        let data: Data?
        
        private enum CodingKeys: String, CodingKey {
            case data
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.data = try container.decodeIfPresent(Data.self, forKey: .data)
            try super.init(from: decoder)
        }
        
        struct Data: Codable {
            let id: Int
            let name: String
            let userid: String
            let password: String

            private enum CodingKeys: String, CodingKey {
                case id
                case name
                case userid
				case password
            }
            
            init(from data: Data) {
                self.id = data.id
                self.name = data.name
                self.userid = data.userid
                self.password = data.password
            }
        }
    }
	
}

let jsonUser: JSON(
	[
		"success": true,
		"update": false,
		"data": JSON(
			[
				"id": 1,
				"name": "Full name of user",
				"userid": "user001",
				"password": "test.123"
			]
		)
	]
)

let user: iFS.Models.User = iFS.Models.shared.decode(json: jsonUser)
```

## Read/write Realm model
Save to Realm entire model:
```
let user: iFS.Models.User = iFS.Models.shared.decode(json: jsonUser, toRealm: true, toRealmUpdate: true)
```
Save to Realm only codable necessary model:
```
extension iFS.Models {

    class User: Base {
        let data: RLM_User?
        
        private enum CodingKeys: String, CodingKey {
            case data
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.data = try container.decodeIfPresent(Data.self, forKey: .data)
            try super.init(from: decoder)
        }
        
    }
	
	class RLM_User: Object, Codable {
		@objc dynamic var id = 0
		@objc dynamic var name = ""
		@objc dynamic var userid = ""
		@objc dynamic var password = ""

		override static func primaryKey() -> String? {
			return #keyPath(RLM_User.id)
		}

		private enum CodingKeys: String, CodingKey {
			case id
			case name
			case userid
			case password
		}

		convenience init(from data: RLM_User) {
			self.init()
			self.id = data.id
			self.name = data.name
			self.userid = data.userid
			self.password = data.password
		}

		convenience required init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			let data = RLM_User()
			data.id = try container.decode(Int.self, forKey: .id)
			data.name = try container.decode(String.self, forKey: .name)
			data.userid = try container.decode(String.self, forKey: .userid)
			data.password = try container.decode(String.self, forKey: .password)
			self.init(from: data)
		}

		required init() {
			super.init()
		}

		required init(value: Any, schema: RLMSchema) {
			super.init(value: value, schema: schema)
		}

		required init(realm: RLMRealm, schema: RLMObjectSchema) {
			super.init(realm: realm, schema: schema)
		}

	}
	
}

if let userToRealm = user.data {
	FsManager.RealmManager.shared.save(nil, content: userToRealm, type: .realmObject, isUpdate: true, completion: { (errorLevel) in
		print("ErrorLevel: \(errorLevel)")
	})
}
```

## Api rest
```
FsManager.Api.shared.rest("Url api rest", .get, [:], nil, .json, true, completion: { (success, result, response, errorLevel, errorMsg) in
	print("Success: \(success)")
	print("Result: \(result)")
	print("Response: \(response)")
	print("ErrorLevel: \(errorLevel)")
	print("ErrorMsg: \(errorMsg)")
})
```

## License
```
The MIT License (MIT)

Copyright (c) 2018 Francesco Sorrentino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
