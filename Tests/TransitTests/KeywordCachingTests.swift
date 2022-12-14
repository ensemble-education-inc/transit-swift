//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/29/22.
//

import Foundation
import Transit
import XCTest

final class KeywordCachingTests: XCTestCase {

    func testDecodingWithTag() throws {

        let data = """
        ["^ ","~:result",["^ ","~:chet-curriculums",["~#list",[["^ ","~:id",43,"~:readable-id","learning-path","~:name","Learning Path","~:display-name",null,"~:order",2,"~:experimental",false],["^ ","^3",76,"^4","featured","^5","Featured","^6",null,"^7",3,"^8",false],["^ ","^3",5,"^4","games-by-topic","^5","Games By Topic","^6",null,"^7",1,"^8",false]]]]]
        """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let result: Result
        }

        struct Result: Codable {
            let curriculums: [Curriculum]

            enum CodingKeys: String, CodingKey {
                case curriculums = "chet-curriculums"
            }
        }

        struct Curriculum: Codable {
            let id: Int
            let readableID: String

            enum CodingKeys: String, CodingKey {
                case id, readableID = "readable-id"
            }

        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.curriculums.first?.id, 43)
        XCTAssertEqual(decoded.result.curriculums.first?.readableID, "learning-path")
    }

    func testCachingKeywordsAsValuesInMaps() throws {

        let data = """
            [\"^ \",\"~:result\",[\"^ \",\"~:named-expressions\",[\"~#list\",[[\"^ \",\"~:id\",1,\"~:name\",\"Starts with a I chord\",\"~:expression\",\"~^I,\",\"~:kind\",\"~:regex\",\"~:location\",null,\"~:scope\",\"~:roman-triads\"],[\"^ \",\"^3\",2,\"^4\",\"Starts with a II chord\",\"^5\",\"~^II,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",3,\"^4\",\"Starts with a IIm chord\",\"^5\",\"~^IIm,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",9,\"^4\",\"First Chord\",\"^5\",\"~^([^,]+)\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",14,\"^4\",\"I, I7, IV\",\"^5\",\"~^I,I7,IV\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"~:roman-tetrachords\"],[\"^ \",\"^3\",17,\"^4\",\"Has a Im chord\",\"^5\",\"(?:^|[,])Im(?:$|[,])\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",18,\"^4\",\"Starts with IIIm\",\"^5\",\"~^IIIm,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",19,\"^4\",\"I, Vm\",\"^5\",\"~^I,Vm,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",20,\"^4\",\"I,Vm,I,IV\",\"^5\",\"~^I,Vm,I,IV,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",22,\"^4\",\"IV, VIm\",\"^5\",\"~^IV,VIm,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",23,\"^4\",\"Im, Vm, IVm\",\"^5\",\"~^Im,Vm,IVm,\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",26,\"^4\",\"I, IV, V triads only\",\"^5\",\"~^(?:(?:(?:I)|(?:IV)|(?:V))(?:,|$))*$\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",27,\"^4\",\"I, IV, V, VIm triads only\",\"^5\",\"~^(?:(?:(?:I)|(?:IV)|(?:V)|(?:VIm))(?:,|$))*$\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",28,\"^4\",\"I, IV, V, VIm, IIm triads only\",\"^5\",\"~^(?:(?:(?:I)|(?:IV)|(?:V)|(?:VIm)|(?:IIm))(?:,|$))*$\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",30,\"^4\",\"I,IIm,IIIm,IV,V,VIm,bVII triads only\",\"^5\",\"~^(?:(?:(?:I)|(?:IV)|(?:V)|(?:IIm)|(?:IIIm)|(?:VIm)|(?:bVII))(?:,|$))*$\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",31,\"^4\",\"I,VII\",\"^5\",\"~^I,VII\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^:\"],[\"^ \",\"^3\",32,\"^4\",\"Chord with a space\",\"^5\",\" \",\"^6\",\"^7\",\"^8\",null,\"^9\",\"~:roman-chords\"],[\"^ \",\"^3\",33,\"^4\",\"Has a power chord\",\"^5\",\"power\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^<\"],[\"^ \",\"^3\",34,\"^4\",\"Has a sus4 chord\",\"^5\",\"sus4\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^<\"],[\"^ \",\"^3\",35,\"^4\",\"Has augmented chord\",\"^5\",\"\\\\+\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^<\"],[\"^ \",\"^3\",36,\"^4\",\"Has a sus2 chord\",\"^5\",\"sus2\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^<\"],[\"^ \",\"^3\",37,\"^4\",\"Has sus but not sus2\",\"^5\",\"sus[^2]\",\"^6\",\"^7\",\"^8\",null,\"^9\",\"^<\"],[\"^ \",\"^3\",7,\"^4\",\"composer xpath\",\"^5\",\"//creator[@type=\\\"composer\\\"]\",\"^6\",\"~:xpath\",\"^8\",null,\"^9\",\"~:main-musicxml\"],[\"^ \",\"^3\",8,\"^4\",\"Tempo-related Tag\",\"^5\",\"boolean(//measure/sound/@tempo | //measure/direction/sound/@tempo | //measure/direction/direction-type/metronome)\",\"^6\",\"^=\",\"^8\",null,\"^9\",\"^>\"],[\"^ \",\"^3\",10,\"^4\",\"Tempo Tags (not metronome)\",\"^5\",\"boolean(//measure/sound/@tempo | //measure/direction/sound/@tempo)\",\"^6\",\"^=\",\"^8\",null,\"^9\",\"^>\"],[\"^ \",\"^3\",15,\"^4\",\"Has 2nd Part\",\"^5\",\"(//part)[2]/@id\",\"^6\",\"^=\",\"^8\",null,\"^9\",\"^>\"],[\"^ \",\"^3\",21,\"^4\",\"Begins with IIIm\",\"^5\",\"IIIm\",\"^6\",\"~:simple\",\"^8\",\"~:start-with\",\"^9\",\"^:\"],[\"^ \",\"^3\",11,\"^4\",\"Has swing\",\"^5\",\"//words[contains(text(),\'swing\')]/text()\",\"^6\",\"^=\",\"^8\",null,\"^9\",\"^>\"],[\"^ \",\"^3\",16,\"^4\",\"The key is \'none\'\",\"^5\",\"boolean(//key/mode[text()=\'none\'])\",\"^6\",\"^=\",\"^8\",null,\"^9\",\"^>\"]]]]]
            """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let result: Result
        }

        struct Result: Codable {
            let namedExpressions: [NamedExpression]

            enum CodingKeys: String, CodingKey {
                case namedExpressions = "named-expressions"
            }
        }

        struct NamedExpression: Codable {
            let id: Int
            let name: String
            let expression: String
            let kind: String
            let location: String?
            let scope: String
        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.namedExpressions[1].kind, "~:regex")
    }

    func testTwoSets() throws {
        let data = """
        ["^ ","~:aaaa",["~#set",[1]],"~:bbbb",["^1",[3]]]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let aaaa: Set<Int>
            let bbbb: Set<Int>
        }

        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.aaaa).sorted(), [1])
        XCTAssertEqual(Array(decoded.bbbb), [3])

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testSingleValueContainer() throws {
        // list_empty.json
        struct KeywordContainer: Codable, Equatable {
            let inner: Keyword

            init(from decoder: Decoder) throws {
                self.inner = try Keyword(from: decoder)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(self.inner)
            }
        }

        let data = """
        ["^ ","~:aaaa","~:hello","~:bbbb","^0"]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let aaaa: KeywordContainer
            let bbbb: KeywordContainer
        }

        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.aaaa.inner, Keyword(keyword: "hello"))

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }


}
