"
I represent a class of matrix operations for Pharo.

I actually wrap a C library of functions that are invoked using the Pharo FFI.
"
Class {
	#name : #Matrix,
	#superclass : #Object,
	#instVars : [
		'array',
		'numRows',
		'numCols'
	],
	#category : #'Matrix-Matrices'
}

{ #category : #'instance creation' }
Matrix class >> newFromArrays: arrays [ 
	"Create a matrix from a 'structured array' that contains row arrays."
	"Examples: 
		Matrix newFromArrays: #( #(1 2 3) #(4 5 6) --> Creates a (2x3)
		Matrix newFromArrays: #( #(1 2 3 ) --> Creates a vector (3x1)
		Matrix newFromArrays: #( #(1) #(2) #(3) ) --> Creates (1x3)
		"
		
	^ self basicNew 
		initializeWithRows: arrays size withColumns: arrays first size;
		fillWithContent: (arrays flatCollect: #yourself);
		yourself
]

{ #category : #'instance creation' }
Matrix class >> newFromHandle: aHandle withRows: numberOfRows withColumns: numberOfColumns [
	"Create a new matrix with a given m x n using a given handle."
	"This is useful when creating a matrix after an FFI operation."
	
	^ self basicNew 
		initializeFromHandle: aHandle 
			withRows: numberOfRows 
			withColumns: numberOfColumns;
		yourself
]

{ #category : #'instance creation' }
Matrix class >> newFromVector: anArray [
	"Create a new n x 1 matrix from a given n-element array."
	
	^ self basicNew 
		initializeWithRows: anArray size withColumns: 1 ;
		fillWithContent: anArray ;
		yourself
]

{ #category : #'instance creation' }
Matrix class >> newWithRows: numberOfRows withColumns: numberOfColumns [
	"Create a new matrix with a given m x n."
	
	^ self basicNew 
		initializeWithRows: numberOfRows withColumns: numberOfColumns;
		yourself
]

{ #category : #arithmetic }
Matrix >> * aScalar [ 
	"Multiply each element in the receiver by a scalar value."
	
	^ self collect: [ :value | value * aScalar ]
]

{ #category : #arithmetic }
Matrix >> + matrixOrVector [ 
	"Add a matrix or a vector to a matrix & reply with a new matrix."
	"If the argument is a matrix, it must be the same dimensions."
	
	| m |
	((numRows = matrixOrVector numRows) 
		and: [ (numCols = matrixOrVector numCols) ])
		ifTrue: [ ^ self add: matrixOrVector ].
		
	matrixOrVector numCols ~= 1
		ifTrue: [ self error: 'not an n x 1 vector' ].
		
	m := matrixOrVector stretchToColumns: numCols.
	^ self + m
]

{ #category : #arithmetic }
Matrix >> +* aMatrix [ 
	"Multiply the m x n receiver by an n x k matrix."
	
	^ self dotProduct: aMatrix
]

{ #category : #arithmetic }
Matrix >> - aMatrix [ 
	"Subtract a matrix from the receiver."
	
	^ self sub: aMatrix
]

{ #category : #arithmetic }
Matrix >> / aScalar [ 
	"Divide each element in the receiver by a scalar value."
	
	^ self collect: [ :value | value / aScalar ]
]

{ #category : #arithmetic }
Matrix >> add: aMatrix [ 
	"Add the argument to the receiver and return a new matrix."
	
	| result resultArray |
	numRows = aMatrix numRows 
		ifFalse: [ self error: 'dimensions are not commensurate' ].
			
	numCols = aMatrix numCols 
		ifFalse: [ self error: 'dimensions are not commensurate' ].
		
	resultArray := ByteArray new: (numRows * aMatrix numCols * 8).
	
	self assert: [ numRows * numCols = array size ].
	self assert: [ aMatrix numRows * aMatrix numCols = aMatrix size ].
	self assert: [ numRows * aMatrix numCols * 8 = resultArray size ].
	self
		add: self getHandle 
		with: numRows 
		with: numCols 
		with: aMatrix getHandle 
		in: resultArray .
		
	result := self class newFromHandle: resultArray withRows: numRows withColumns: numCols.
	^ result
]

{ #category : #arithmetic }
Matrix >> add: matrix1 with: numberOfRows with: numberOfColumns with: matrix2 in: result [
	
	^ self 
		ffiCall: #(void add(
			double *matrix1, 
			int numberOfRows, 
			int numberOfColumns, 
			double *matrix2, 
			double *result))
		module: 'libmatrix.so'
]

{ #category : #accessing }
Matrix >> array [
	"Reply with the array containing the matrix values."
	"Note that this array was created by the FFI library, so "
	"these are values of a type external to Pharo (doubles)."

	^ array
]

{ #category : #accessing }
Matrix >> asArray [ 
	"Reply with the 'array' as a Pharo Array of Pharo floats."
	
	^ array asArray 
]

{ #category : #accessing }
Matrix >> asStructuredArray [ 
	"Reply with the 'array' as a Pharo Array of Arrays of Pharo floats."
	
	^ (1 to: numRows) collect: [ :index |
		self atRow: index ] as: Array
]

{ #category : #accessing }
Matrix >> at: aPoint [
	"Reply with an element of the matrix at (x, y)."
	"Convert x & y into a linear offset into the array of values."
	"Note that the foreign (C) type array is 0-based, in Pharo it is 1-based."
	
	^ array at: ((aPoint x - 1) * numCols + (aPoint y - 1)) + 1
]

{ #category : #accessing }
Matrix >> at: aPoint put: aNumber [
	"Overwrite an element of the matrix at (x, y)."
	"Convert x & y into a linear offset into the array of values."
	"Note that the foreign (C) type array is 0-based, in Pharo it is 1-based."
	
	array 
		at: ((aPoint x - 1) * numCols + (aPoint y - 1)) + 1
		put: aNumber asFloat
]

{ #category : #accessing }
Matrix >> atRow: rowNumber [
	"Reply with an entire row (array) of the matrix."
	"Note that the foreign (C) type array is 0-based, in Pharo it is 1-based."
	
	(rowNumber between: 1 and: rowNumber)
		ifFalse: [ self error: 'row index is out of range' ].
	
	^ (1 to: numCols) collect: [ :col |
		self at: rowNumber @ col ]
]

{ #category : #arithmetic }
Matrix >> collect: aOneArgBlock [ 
	"Override to 'collect:' to operate on each element of a matrix."
	
	| result |
	result := self class newWithRows: numRows withColumns: numCols.
	1 to: numRows do: [ :row | 
		1 to: numCols do: [ :col |
			result 
				at: (row @ col) 
				put: (aOneArgBlock value: (self at: (row @ col))) .
			].
		].
	^ result
]

{ #category : #arithmetic }
Matrix >> dot: array1 with: numRows1 with: numCols1 with: array2 	with: numRows2 with: numCols2 in: result [
	"Replace the result (handle) with the dot product of 
	the first matrix (as array) with the second matrix (as array)."
	
	^ self 
		ffiCall: #(void dot( 
			void *array1, int numRows1, int numCols1, 
			void *array2, int numRows2, int numCols2, 
			void *result ) )
		module: 'libmatrix.so' 
	
]

{ #category : #arithmetic }
Matrix >> dotProduct: aMatrix [
	"Reply with the dot product of an m x n matrix with an n x k matrix."
	
	| result resultArray |
	numCols = aMatrix numRows 
		ifFalse: [ self error: 'dimensions are not commensurate' ].
	self assert: [ numRows * numCols = array size ].
	self assert: [ aMatrix numRows * aMatrix numCols = aMatrix size ].
	
	resultArray := ByteArray new: (numRows * aMatrix numCols * 8).
	self 
		dot: self getHandle with: numRows with: numCols 
		with: aMatrix getHandle 
		with: aMatrix numRows with: aMatrix numCols 
		in: resultArray .
		
	result := self class 
		newFromHandle: resultArray 
		withRows: numRows 
		withColumns: aMatrix numCols .
	^ result 
	
]

{ #category : #accessing }
Matrix >> fillWithContent: content [ 
	"Initialize a matrix by copying a linear array of data to its cells."
	"The matrix is an array of doubles in row-major order."
	
	self assert: [ content size = (numRows * numCols) ]
		description: 'content size is not commensurate with matrix size'.
		
	content doWithIndex: [ :value :index | 
		array at: index put: value ]
]

{ #category : #accessing }
Matrix >> getHandle [ 
	"Reply with the handle of the matrix (as a foreign object)."
	"The C library requires a handle for access, not a Pharo object."
	
	^ array getHandle
]

{ #category : #'instance creation' }
Matrix >> initializeFromHandle: aHandle withRows: numberOfRows withColumns: numberOfColumns [
	"Initialize a new matrix with a given m x n using a given handle."
	"This is useful when creating a matrix after an FFI operation."
	
	self initialize. 
	numRows := numberOfRows .
	numCols := numberOfColumns .
	array := self newArrayFromHandle: aHandle
]

{ #category : #initialization }
Matrix >> initializeWithRows: numberOfRows withColumns: numberOfCols [
	"Create and initialize new matrix with a given mxn."
	
	self initialize .
	numRows := numberOfRows.
	numCols := numberOfCols.
	array := self newArray
]

{ #category : #accessing }
Matrix >> max [ 
	"Reply with the largest value in the matrix."
	
	^ self asArray max
]

{ #category : #arithmetic }
Matrix >> multiplyPerElement: aMatrix [ 
	"Multiply two matrices together, element to element (not dot product)."
	
	| result |
	self assert: [ numRows = aMatrix numRows ].
	self assert: [ numCols = aMatrix numCols ].
	
	result := self class newWithRows: numRows withColumns: numCols .
	
	result fillWithContent: (self asArray 
			with: aMatrix array asArray 
			collect: [ :a :b | a * b ] ).
	^ result
]

{ #category : #'instance creation' }
Matrix >> newArray [ 
	"Create a new array used to store the matrix content."
	
	^ FFIExternalArray 
		newType: 'double' 
		size: numRows * numCols 
]

{ #category : #'instance creation' }
Matrix >> newArrayFromHandle: aHandle [
	"Create an external array using a given handle."
	
	^ FFIExternalArray 
		fromHandle: aHandle 
		type: 'double' 
		size: numRows * numCols
]

{ #category : #accessing }
Matrix >> numCols [
	"Reply with the number of columns in the matrix."

	^ numCols
]

{ #category : #accessing }
Matrix >> numRows [
	"Reply with the number of rows in the matrix."

	^ numRows
]

{ #category : #printing }
Matrix >> printOn: aStream [
	"Print the matrix on the stream, limited to 4 decimal places."
	
	self printOn: aStream roundTo: 4
]

{ #category : #printing }
Matrix >> printOn: aStream roundTo: numDecimals [ 
	"Print the receiver on a stream, with all decimals rounded off."
	
	aStream nextPutAll: '('.
	(1 to: numRows) do: [ :row |
		(self atRow: row) do: [ :each | 
			aStream nextPutAll: 
				(each round: numDecimals) printString 
			] separatedBy: [ aStream space ] 
		] separatedBy: [ aStream cr ].
	aStream nextPutAll: ' )'
]

{ #category : #accessing }
Matrix >> randomize [ 
	"Fill the matrix with random numbers."
	
	^ self randomize: Random new
]

{ #category : #accessing }
Matrix >> randomize: randomGenerator [ 
	"Fill the matrix with random numbers generated by the provided generator."
	
	self fillWithContent: (
		(1 to: numRows * numCols) collect: [ :notUsed | 
			randomGenerator next ]
		)
]

{ #category : #accessing }
Matrix >> size [
	"Reply with the number of values in the matrix."

	^ numRows * numCols 
]

{ #category : #arithmetic }
Matrix >> stretchToColumns: numberOfColumns [
	"Replicate a n x 1 vector into m columns of a new matrix."
	
	| result content |
	content := OrderedCollection new.
	1 to: numRows do: [ :row | 
		1 to: numberOfColumns do: [ :col |
			content add: (self at: (row @ 1))
			].
		].
	
	result := self class newWithRows: numRows withColumns: numberOfColumns .
	result fillWithContent: content.
	^ result
]

{ #category : #arithmetic }
Matrix >> sub: aMatrix [ 
	"Add the argument to the receiver and return a new matrix."
	
	| result resultArray |
	numRows = aMatrix numRows 
		ifFalse: [ self error: 'dimensions are not commensurate' ].
			
	numCols = aMatrix numCols 
		ifFalse: [ self error: 'dimensions are not commensurate' ].
		
	resultArray := ByteArray new: (numRows * aMatrix numCols * 8).
	
	self assert: [ numRows * numCols = array size ].
	self assert: [ aMatrix numRows * aMatrix numCols = aMatrix size ].
	self assert: [ numRows * aMatrix numCols * 8 = resultArray size ].
	self
		sub: self getHandle 
		with: numRows 
		with: numCols 
		with: aMatrix getHandle 
		in: resultArray .
		
	result := self class newFromHandle: resultArray withRows: numRows withColumns: numCols.
	^ result
]

{ #category : #arithmetic }
Matrix >> sub: matrix1 with: numberOfRows with: numberOfColumns with: matrix2 in: result [
	
	^ self 
		ffiCall: #(void sub(
			double *matrix1, 
			int numberOfRows, 
			int numberOfColumns, 
			double *matrix2, 
			double *result))
		module: 'libmatrix.so'
]

{ #category : #arithmetic }
Matrix >> sum [
	"Reply with the sum of all the elements in the receiver."
	
	| sum |
	sum := 0.
	1 to: numRows do: [ :row | 
		1 to: numCols do: [ :col |
			sum := sum + (self at: (row @ col)) .
			].
		].
	^ sum
]

{ #category : #arithmetic }
Matrix >> sumHorizontal [ 
	"Reply with a vector, where each row is the sum of the columns of the receiver."
	
	| result sum |
	result := self class newWithRows: numRows withColumns: 1.
	1 to: numRows do: [ :row | 
		sum := 0.
		1 to: numCols do: [ :col |
			sum := sum + (self at: (row @ col)) .
			].
		result at: (row @ 1) put: sum.
		].
	^ result
]

{ #category : #arithmetic }
Matrix >> transposed [
	"Reply with a matrix of the receiver transposed."
	
	| result |
	result := self class newWithRows: numCols withColumns: numRows .
	1 to: numRows do: [ :row | 
		1 to: numCols do: [ :col |
			result at: (col @ row) put: (self at: (row @ col)) .
			].
		].
	^ result
]
