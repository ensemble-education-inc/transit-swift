import Transit
import XCTest

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
	
}
