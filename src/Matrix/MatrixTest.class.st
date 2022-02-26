Class {
	#name : #MatrixTest,
	#superclass : #TestCase,
	#category : #'Matrix-Tests'
}

{ #category : #tests }
MatrixTest >> testAddition1 [

	| m1 m2 |
	m1 := Matrix newFromArrays: #( #(1 2 3) #(4 5 6) ).
	m2 := Matrix newFromArrays: #( #(4 5 6) #(1 2 3) ).
	
	self assert: (m1 + m2) asStructuredArray 
		equals: #( #(5.0 7.0 9.0) #(5.0 7.0 9.0) )
]

{ #category : #tests }
MatrixTest >> testAddition2 [

	| m |
	m := Matrix newFromArrays: #( #(1 2 3) #(4 5 6) ).
	
	self assert: (m + m) asStructuredArray 
		equals: #( #(2.0 4.0 6.0) #(8.0 10.0 12.0) )
]

{ #category : #tests }
MatrixTest >> testAt [
	"Test accessing a matrix value from row & column indices."

	| m |
	m := Matrix newFromArrays: #( #(1 2) #(3 4) ).
	
	self assert: (m at: 1 @ 1) equals: 1.
	self assert: (m at: 1 @ 2) equals: 2.
	self assert: (m at: 2 @ 1) equals: 3.
	self assert: (m at: 2 @ 2) equals: 4.
]

{ #category : #tests }
MatrixTest >> testAtPut [
	"Test modifying a matrix value using row & column indices."

	| m |
	m := Matrix newFromArrays: #( #(1 2) #(3 4) ).
	m at: (2 @ 1) put: 10.0.
	
	self assert: (m at: 2 @ 1) equals: 10.0.
	self assert: m asStructuredArray equals: #( #(1 2) #(10 4) )
]

{ #category : #tests }
MatrixTest >> testCollect [

	| m expected |
	m := Matrix newFromArrays: #( #(1 2 3) #(4 5 6) ).
	
	expected := Matrix newFromArrays: #( #(2 3 4) #(5 6 7) ).
	
	self 
		assert: (m collect: [ :value | value + 1 ]) asStructuredArray 
		equals: expected asStructuredArray 
]

{ #category : #tests }
MatrixTest >> testCreation [ 
	"Test creating a matrix from row arrays, converting to an array."

	| m |
	m := Matrix newFromArrays: #( #(1 2) #(3 4) ).
	
	self assert: m asArray equals: #(1.0 2.0 3.0 4.0).
]

{ #category : #tests }
MatrixTest >> testDivisionOnMatrix [

	| m |
	m := Matrix newFromArrays: #( #(1 2 3) #(4 5 6) ).
	
	self assert: (m / 2) asStructuredArray 
		equals: #( #(0.5 1.0 1.5) #(2.0 2.5 3.0) )
]

{ #category : #tests }
MatrixTest >> testMatrixDotProduct [

	| m1 m2 |
	m1 := Matrix newFromArrays: #( #(1 2 3 4) #(5 6 7 8) ).
	m2 := Matrix newFromArrays: #( #(1 2) #(3 4) #(5 6) #(7 8) ).
	
	self assert: (m1 +* m2) asStructuredArray 
		equals: #( #(50.0 60.0) #(114.0 140.0) )
]

{ #category : #tests }
MatrixTest >> testMax [
	"Test finding the largest value in a matrix."

	| m |
	m := Matrix newFromArrays: #( #(1 2) #(3 4) ).
	
	self assert: m max equals: 4
]

{ #category : #tests }
MatrixTest >> testMultiplicationOnMatrix [

	| m |
	m := Matrix newFromArrays: #( #(1 2 3 4) #(10 20 30 40) ).
	
	self assert: (m * 5) asStructuredArray 
		equals: #( #(5.0 10.0 15.0 20.0) #(50.0 100.0 150.0 200.0) )
]

{ #category : #tests }
MatrixTest >> testMultiplicationOnVector [

	| x |
	x := Matrix newFromVector: #(1 2 3 4).
	
	self assert: (x * 5) asStructuredArray 
		equals: #( #(5.0) #(10.0) #(15.0) #(20.0) )
]

{ #category : #tests }
MatrixTest >> testMultiplicationPerElement [

	| vector1 vector2 expected |
	vector1 := Matrix newFromVector: #(1 2 3).
	vector2 := Matrix newFromVector: #(10 20 30).
	expected := Matrix newFromVector: #(10 40 90).
	
	self assert: (vector1 multiplyPerElement: vector2) asArray 
		equals: expected asArray
]

{ #category : #tests }
MatrixTest >> testStretching [

	| m |
	m := (Matrix newFromVector: #( 1 2 3 4)) stretchToColumns: 5.
	
	self assert: m numRows equals: 4.
	self assert: m numCols equals: 5.
	self assert: (m atRow: 1) equals: #(1 1 1 1 1).
	self assert: (m atRow: 3) equals: #(3 3 3 3 3).
]

{ #category : #tests }
MatrixTest >> testSubtraction [

	| m1 m2 |
	m1 := Matrix newFromArrays: #( #(1 2 3 4) #(5 6 7 8) ).
	m2 := Matrix newFromArrays: #( #(4 2 1 3) #(7 6 8 5) ).
	
	self assert: (m1 - m2) asStructuredArray 
		equals: #( #(-3 0 2 1) #(-2 0 -1 3) )
]

{ #category : #tests }
MatrixTest >> testSum [

	| m |
	m := Matrix newFromArrays: #( #(1 2 3 4) #(5 6 7 8) ).
	
	self assert: m sum equals: (1 to: 8) sum
]

{ #category : #tests }
MatrixTest >> testSumHorizontal [

	| m expected |
	m := Matrix newFromArrays: #( #(1 2) #(3 4) #(5 6) ).
	
	expected := Matrix newFromArrays: #( #(3) #(7) #(11) ).
	
	self assert: m sumHorizontal asStructuredArray 
		equals: expected asStructuredArray 
]

{ #category : #tests }
MatrixTest >> testTransposed [

	| m expected |
	m := Matrix newFromArrays: #( #(1 2 3 4) #(5 6 7 8) ).
	
	expected := Matrix newFromArrays: #( #(1 5) #(2 6) #(3 7) #(4 8) ).
	
	self assert: m transposed asStructuredArray 
		equals: expected asStructuredArray 
]

{ #category : #tests }
MatrixTest >> testTransposedOnVector [

	| m |
	m := Matrix newFromVector: #(1 2 3).
	
	self assert: m transposed asStructuredArray 
		equals: #( #(1 2 3) )
]

{ #category : #tests }
MatrixTest >> testVectorCreation [

	| v |
	v := Matrix newFromVector: #( 1 2 3 ).
	
	self assert: v numCols equals: 1.
	self assert: v numRows equals: 3.
	self assert: v asStructuredArray equals: #( #(1) #(2) #(3) )
]
