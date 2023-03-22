import Foundation
import Transit
import XCTest

struct RequestIdentifier: Equatable, Hashable, Codable {
		let rawValue: String

		init(rawValue: String) {
				self.rawValue = rawValue
		}

		init() {
				rawValue = (0..<3)
						.map({ _ in
								UInt8.random(in: 0..<UInt8.max)
						})
						.map({ String(format: "%02X", $0) })
						.joined()
		}

		enum CodingKeys: CodingKey {
				case rawValue
		}

		func encode(to encoder: Encoder) throws {
				var container = encoder.singleValueContainer()
				try container.encode(self.rawValue)
		}

		init(from decoder: Decoder) throws {
				let container = try decoder.singleValueContainer()

				let rawString = try container.decode(String.self)

				guard satisfies(rawString) else {
						throw DecodingError
								.dataCorrupted(.init(
										codingPath: decoder.codingPath,
										debugDescription: "Request identifier not well formed"
								))
				}

				self.rawValue = rawString
		}

}

func satisfies(_ string: String) -> Bool {
	return string.count == 6 && string.allSatisfy ({ $0.isLetter || $0.isNumber })
}

extension Array {
		func requestIdentifer<T>() -> RequestIdentifier? where Element == APIResult<T> {
				return self.lazy.compactMap({ value in
						switch value {
						case let .requestID(id):
								return id
						default:
								return nil
						}
				}).first
		}
}

struct SimpleAPIError: Error, Codable {
		let string: String

		init(from decoder: Decoder) throws {
				let container = try decoder.singleValueContainer()
				self.string = try container.decode(String.self)
		}

		enum CodingKeys: CodingKey {
				case string
		}

		func encode(to encoder: Encoder) throws {
				var container = encoder.singleValueContainer()
				try container.encode(self.string)
		}
}

enum APIResult<T: Decodable>: Decodable {
		case result(T)
		case requestID(RequestIdentifier)
		case error(SimpleAPIError)

		enum CodingKeys: CodingKey {
				case result
				case requestID
				case error
		}

		init(from decoder: Decoder) throws {
				do {
						let container = try decoder.singleValueContainer()
						let identifier = try container.decode(String.self)
						if satisfies(identifier) {
								throw DecodingError
										.dataCorrupted(.init(
												codingPath: decoder.codingPath,
												debugDescription: "Request identifier not well formed"
										))
						}
						self = .requestID(.init(rawValue: identifier))
				} catch {
						let container = try decoder.container(keyedBy: CodingKeys.self)
						do {
								self = .result(try container.decode(T.self, forKey: .result))
						} catch {
								do {
										self = .error(try container.decode(SimpleAPIError.self, forKey: .error))
								} catch {
										throw error
								}
						}
				}
		}
}

struct RequestIdentifierContainer: Decodable {
		enum CodingKeys: CodingKey {
				case requestID
		}

		let requestIdentifier: RequestIdentifier

		init(from decoder: Decoder) throws {
				var container = try decoder.unkeyedContainer()
				while !container.isAtEnd {
						do {
								let next = try container.decode(String.self)
								if satisfies(next) {
										self.requestIdentifier = RequestIdentifier(rawValue: next)
										return
								}
						} catch {
								try container.skip()
						}
				}
				throw DecodingError.keyNotFound(
						CodingKeys.requestID,
						.init(codingPath: decoder.codingPath, debugDescription: "No request identifier found.")
				)
		}
}

struct Empty: Decodable { }

public extension UnkeyedDecodingContainer {
		mutating func skip() throws {
				_ = try decode(Empty.self)
		}
}


final class TransitTests: XCTestCase {

	func testDecoding() throws {
			let data = """
							[
								"^ ",
								"~:result",
								[
									"^ ",
									"~:workspaces",
									[
										"~:strayhorn",
										"~:chet",
										"~:ella"
									],
									"~:id",
									9,
									"~:username",
									"s@s.net",
									"~:staff?",
									false,
									"~:superuser?",
									false,
									"~:preferences",
									[
										"^ ",
										"~:chet/games",
										[
											"^ ",
											"~:filter",
											[
												"^ ",
												"^5",
												[
													11309
												]
											],
											"~:chet-games/badges",
											[
												"~#set",
												[
													"~:question-count"
												]
											]
										],
										"~:chet/questions",
										[
											"^ ",
											"^;",
											[
												"^ ",
												"^5",
												[
													26517
												]
											]
										]
									]
								]
							]
						"""
				.data(using: .utf8)!
    
        struct Decoded: Codable {
            let result: Result
        }

        struct Result: Codable {
            let id: Int
            let username: String
            let superuser: Bool
            let staff: Bool
            let workspaces: [Keyword]
            let preferences: Preferences

            enum CodingKeys: String, CodingKey {
                case workspaces
                case id
                case username
                case staff = "staff?"
                case superuser = "superuser?"
                case preferences
            }
        }

        struct Preferences: Codable {
            let chetGames: ChetGames

            enum CodingKeys: String, CodingKey {
                case chetGames = "chet/games"
            }
        }

        struct ChetGames: Codable {
            let filter: Filter
            struct Filter: Codable {
                let id: [Int]
            }
        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, "s@s.net")
        XCTAssertEqual(decoded.result.id, 9)
        XCTAssertEqual(decoded.result.superuser, false)
        XCTAssertEqual(decoded.result.staff, false)
        XCTAssertEqual(decoded.result.workspaces.count, 3)
        XCTAssertEqual(decoded.result.workspaces.map(\.rawValue), ["strayhorn", "chet", "ella"])
        XCTAssertEqual(decoded.result.preferences.chetGames.filter.id.first, 11309)
    }
	
	func testCachingDecodingWorksAsExpected() throws {
		let data = """
			 [["^ ","~:result",["^ ","~:data",["^ ","~:chet-questions",["~#list",[["^ ","~:transposition-type","To Tonic","~:piano-octave-adjustment",0,"~:multiple-choice-possible-answers-override",false,"~:bass-rating",null,"~:rating-synced-at",null,"~:correct-feedback-override",false,"~:guitar-octave-adjustment",0,"~:correct-feedback",null,"~:instructions",null,"~:instructions-override",false,"~:question-type-override",false,"~:piano-rating",1000,"~:transpose-max-key-signature-accidentals",6,"~:experimental",false,"~:transposition-type-override",false,"~:possible-intervals",null,"~:guitar-rating",null,"~:possible-pitches",null,"~:piano-octave-adjustment-override",false,"~:title","The Lord of The Rings - Howard Shore -sk","~:transpose-key-signature-override",false,"~:title-override",false,"~:question-type","call_and_response_sequence","~:validator-version","v219","~:multiple-choice-correct-answer-override",false,"~:archive-date",null,"~:possible-pitches-override",false,"~:algorithmic",false,"~:id",26868,"~:audio-id","chet/Lord of the rings new_-23-26868-70c9b18a8f0b6595021a204830db61a9.m4a","~:multiple-choice-correct-answer",null,"~:bass-octave-adjustment",0,"~:content-type","Tune","~:possible-intervals-override",false,"~:main-notes","[L:1/4] [K:Cminor] [M:4/4] [Q:1/4=100] C2 B,3/2 G,//B,// C2","~:error",null,"~:transpose-key-signature",true,"~:guitar-octave-adjustment-override",false,"~:algorithmic-length",null,"~:midi-notes-offsets",null,"~:experimental-override",false,"~:multiple-choice-possible-answers",null,"~:transpose-max-key-signature-accidentals-override",false,"~:template-id",null,"~:bass-octave-adjustment-override",false,"~:content-type-override",false]]],"~:chet-question-tag-ties",["^3",[["^ ","^P",133,"~:question-id",26868,"~:tag-id",68],["^ ","^P",224,"^17",26868,"^18",47],["^ ","^P",225,"^17",26868,"^18",64]]],"~:chet-question-feedback",["^3",[]],"~:chet-question-game-ties",["^3",[["^ ","^P",29131,"^17",26868,"~:sub-game-id",null,"~:game-id",11257,"~:order",3,"~:game-name","Level 14","~:game-archive-date",null]]]],"~:ordered-ids",[26868],"~:pagination",["^ ","~:pages",1,"~:page",1,"~:items",1]]],"DDC2C5"]
		"""
			.data(using: .utf8)!
		
		struct ID<Model>: Codable, RawRepresentable, Hashable, CustomStringConvertible {
				init?(rawValue: Int) {
						self.rawValue = rawValue
				}

				let rawValue: Int

				init(from decoder: Decoder) throws {
						let container = try decoder.singleValueContainer()
						self.rawValue = try container.decode(Int.self)
				}

				func encode(to encoder: Encoder) throws {
						var container = encoder.singleValueContainer()
						try container.encode(rawValue)
				}

				var description: String {
						rawValue.description
				}
		}
		
		struct IdentityMap<Value: Identifiable & Codable>: Codable where Value.ID == ID<Value> {
				let values: [ID<Value>: Value]

				init(from decoder: Decoder) throws {
						var container = try decoder.unkeyedContainer()
						var _values: [ID<Value>: Value] = [:]
						while !container.isAtEnd {
								let next = try container.decode(Value.self)
								_values[next.id] = next
						}
						self.values = _values
				}

				func encode(to encoder: Encoder) throws {
						var container = encoder.unkeyedContainer()
						for value in values.values {
								try container.encode(value)
						}
				}
		}

		struct ChetQuestionTagTies: Codable, Equatable, Identifiable {
			var id: ID<Self>
			var tagID: Int?
			var questionID: Int
			
			enum CodingKeys: String, CodingKey {
				case id = "id"
				case tagID = "tag-id"
				case questionID = "question-id"
			}
		}
		
		enum APIResult<T: Decodable>: Decodable {
			case result(T)
			case requestID(RequestIdentifier)
			case error(SimpleAPIError)
			
			enum CodingKeys: CodingKey {
				case result
				case requestID
				case error
			}
			
			init(from decoder: Decoder) throws {
				do {
					let container = try decoder.singleValueContainer()
					let identifier = try container.decode(String.self)
					if satisfies(identifier) {
						throw DecodingError
							.dataCorrupted(.init(
								codingPath: decoder.codingPath,
								debugDescription: "Request identifier not well formed"
							))
					}
					self = .requestID(.init(rawValue: identifier))
				} catch {
					let container = try decoder.container(keyedBy: CodingKeys.self)
					do {
						self = .result(try container.decode(T.self, forKey: .result))
					} catch {
						fatalError()
					}
				}
			}
		}
		
		struct DataValues: Codable {
				let chetQuestionTagTies: IdentityMap<ChetQuestionTagTies>?

				enum CodingKeys: String, CodingKey {
						case chetQuestionTagTies = "chet-question-tag-ties"
				}
		}

		struct DataContainer<IDType: Codable>: Codable {
				let _data: DataValues

				enum CodingKeys: String, CodingKey {
						case _data = "data"
				}
		}
		
		let decoded = try TransitDecoder().decode([DataContainer<DataValues>].self, from: data)
		
		XCTAssertNotNil(decoded)
		
	}
	
}
