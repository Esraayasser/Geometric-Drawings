INCLUDE Irvine32.inc

.DATA
;================================================================================================================================================================================================================================================

fileName BYTE "lines.txt", 0 ;doesn't have to be a path if it's in the project's folder

maxSize equ 400 ;won't be changed
actualSize DWORD ? ;actual number of bytes/coordinates (X's + Y's), will be determined during run-time (the converting PROC)
numOfPoints BYTE ? ;actualSize / 2
numOfLines BYTE ? ;numOfPoints / 2

inputLines BYTE maxSize DUP(?) ; input buffer containing the characters in the file
pointsList BYTE maxSize DUP(?) ; contains the converted integers
xList BYTE maxSize DUP(?) ; x coordinates {startL1, endL1, startL2, endL2, startL3, ...}
yList BYTE maxSize DUP(?) ; y coordinates {startL1, endL1, startL2, endL2, startL3, ...}

numOfBytesTriangles DWORD ?  ;used as an index with the offset of pointsTrianglesList
							 ;to know where to insert the next element
numOfPointsTriangles DWORD ? ;actual number of points
numOfTriangles DWORD ?
pointsTrianglesList DWORD maxSize DUP(?) ;indices of the points of the detected triangles in xList/yList

xRectanglesList BYTE 45 DUP(?)      ; Carries the x-coordinates of the found Rectangles {x1_1, x1_2, x1_3, x1_4, x2_1, x2_2, x2_3, x2_4, ...}
yRectanglesList BYTE 45 DUP(?)      ; Carries the y-coordinates of the found Rectangles {y1_1, y1_2, y1_3, y1_4, y2_1, y2_2, y2_3, y2_4, ...}
rectanglesNumber DWORD 0            ; Carries the number of the found Rectangles
xSquaresList BYTE 45 DUP(?)         ; Carries the x-coordinates of the found Squares {x1_1, x1_2, x1_3, x1_4, x2_1, x2_2, x2_3, x2_4, ...}
ySquaresList BYTE 45 DUP(?)         ; Carries the y-coordinates of the found Squares {y1_1, y1_2, y1_3, y1_4, y2_1, y2_2, y2_3, y2_4, ...}
squaresNumber DWORD 0               ; Carries the number of the found Squares

intersectionsNumber DWORD 0			; The Number of found intersections
xIntersections BYTE 400 DUP(?)		; Carries the x-coordinates of the found Intersections {x1, x2, x3, x4,....}
yIntersections BYTE 400 DUP(?)		; Carries the y-coordinates of the found Intersections {x1, x2, x3, x4,....}
isDistinctIntersection BYTE 0		; To validate wether the found intersection was found before or not
validRec BYTE 0						; To validate that there actually is lines connecting the found 4 poinst and forming a rectangle/square

xFirstPointOffset DWORD ?			;Used to store the offset of the x-coordinate first point in the nested loops used in the search for the 4 points of the rectangles/squares and in the nested loop used to find intersections
yFirstPointOffset DWORD ?			;Used to store the offset of the y-coordinate first point in the nested loops used in the search for the 4 points of the rectangles/squares
xSecondPointOffset DWORD ?			;Used to store the offset of the x-coordinate second point in the nested loops used in the search for the 4 points of the rectangles/squares
ySecondPointOffset DWORD ?			;Used to store the offset of the y-coordinate second point in the nested loops used in the search for the 4 points of the rectangles/squares
xThirdPointOffset DWORD ?			;Used to store the offset of the x-coordinate third point in the nested loops used in the search for the 4 points of the rectangles/squares
yThirdPointOffset DWORD ?			;Used to store the offset of the y-coordinate third point in the nested loops used in the search for the 4 points of the rectangles/squares
xFourthPointOffset DWORD ?			;Used to store the offset of the x-coordinate fourth point in the nested loops used in the search for the 4 points of the rectangles/squares
yFourthPointOffset DWORD ?			;Used to store the offset of the y-coordinate fourth point in the nested loops used in the search for the 4 points of the rectangles/squares

xStCurPoint BYTE ?                  ; The x-coordinate of the start of the current line used in the search for intersections
xEnCurPoint BYTE ?                  ; The x-coordinate of the end of the current line used in the search for intersections
yStCurPoint BYTE ?                  ; The y-coordinate of the start of the current line used in the search for intersections
yEnCurPoint BYTE ?                  ; The y-coordinate of the end of the current line used in the search for intersections 
                                    
xCurOffset1 DWORD ?                 ; Used to save the cur offset of the xList in the nested loops used for the search for th intersections
yCurOffset1 DWORD ?                 ; Used to save the cur offset of the yList in the nested loops used for the search for th intersections

xSquaresOffset DWORD ?              ; Used to store the offset of the last cell in the xSquaresList to store the new values of the new square in
ySquaresOffset DWORD ?              ; Used to store the offset of the last cell in the ySquaresList to store the new values of the new square in
xRectanglesOffset DWORD ?           ; Used to store the offset of the last cell in the xRectanglesList to store the new values of the new rectangle in
yRectanglesOffset DWORD ?           ; Used to store the offset of the last cell in the yRectanglesList to store the new values of the new rectangle in
                                    
tmp1stPointECX DWORD ?				;
tmp2ndPointECX DWORD ?				;
tmp3rdPointECX DWORD ?				; ALL 4 are used as a temp containers for the ECX register values in the nested 4 loops used in the search for rectangles/squares
tmp4thPointECX DWORD ?              ;  
tmpValidatePointECX DWORD  ?        ; Used to store the values of the ECX register in the validation of the found intersection point
tmpValidateRecECX DWORD  ?			; Used to store the values of the ECX register in the validation of the found rectangle/square

x BYTE ?							; Used as the x-coordinate of the found intersection point in the validation of it
y BYTE ?							; Used as the y-coordinate of the found intersection point in the validation of it
x5 BYTE ?							; Used as the x-coordinate in the validation of the found rectangle/square
y5 BYTE ?							; Used as the y-coordinate in the validation of the found rectangle/square
x1 BYTE ?							; Used as the x-coordinate of the found First point in the validation of the rectangle points
y1 BYTE ?							; Used as the y-coordinate of the found First point in the validation of the rectangle points
x2 BYTE ?							; Used as the x-coordinate of the found Second point in the validation of the rectangle points
y2 BYTE ?							; Used as the y-coordinate of the found Second point in the validation of the rectangle points
x3 BYTE ?							; Used as the x-coordinate of the found Third point in the validation of the rectangle points
y3 BYTE ?							; Used as the y-coordinate of the found Third point in the validation of the rectangle points
x4 BYTE ?							; Used as the x-coordinate of the found Fourth point in the validation of the rectangle points
y4 BYTE ?							; Used as the y-coordinate of the found Fourth point in the validation of the rectangle points
line BYTE ?							; Used to indicate the line that we're check whether it exists in the input or not

;================================================================================================================================================================================================================================================


.CODE
;================================================================================================================================================================================================================================================

main PROC
	CALL ReadLines

	mov ESI, OFFSET inputLines	; list of characters
	mov EDI, OFFSET pointsList	; list to be filled with numbers
	CALL ConvertCharsToNumbers
	;call writeDec
	mov actualSize, EAX ; EAX has the number of converted integers

	mov EDX, OFFSET pointsList
	mov ECX, actualSize
	mov ESI, OFFSET xList
	mov EDI, OFFSET yList
	;mov xNumberElement, 0
	;mov yNumberElement, 0
	CALL DivideIntoXY

	mov EAX, actualSize
	CALL DivideByTwo      ;getting # points = # of bytes (actualSize) / 2
	mov numOfPoints, AL   ;EAX contains actualSize / 2
	CALL DivideByTwo      ;getting # of lines = # of points (EAX) / 2
	mov numOfLines, AL	  ;EAX contains numOfPoints / 2

	;movzx ECX, numOfPoints
	;mov EDX, offset xList
	;coutXs:
		;movzx EAX, BYTE ptr [EDX]
		;CALL WriteInt
		;CALL CRLF
		;inc EDX
	;LOOP coutXs

	;triangles + example of the output (to understand what my PROCs do)
	CALL FindTriangles
	mov EAX, numOfTriangles
	CALL WriteDec ;number of triangles
	CALL CRLF
	CALL CRLF
	cmp numOfTriangles, 0
	JE noTrianglesFound
	mov ECX, numOfPointsTriangles
	mov EDX, offset pointsTrianglesList
	mov ESI, 0 ;points counter
	outputTriangles:
		mov AL, '('
		CALL WriteChar

		mov EBX, [EDX] ;index of the point in xList and yList
		mov EDI, offset xList
		add EDI, EBX
		movzx EAX, BYTE ptr [EDI]
		CALL WriteInt  ;x coordinate of the point
		
		mov AL, ','
		CALL WriteChar
		mov AL, ' '
		CALL WriteChar

		mov EDI, offset yList
		add EDI, EBX
		movzx EAX, BYTE ptr [EDI] ;y coordinate of the point
		CALL WriteInt

		mov AL, ')'
		CALL WriteChar

		CALL CRLF
		add EDX, type pointsTrianglesList

		inc ESI
		cmp ESI, 3
		JNE triangleNotDone
		mov ESI, 0
		CALL CRLF

		triangleNotDone:
	loop outputTriangles
	noTrianglesFound:

	CALL findRectanglesAndSquares

exit
main ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ReadLines PROC
	mov EDX, offset fileName
	CALL OpenFile ;returns fileHandle in EAX

	mov ECX, maxSize
	mov EDX, offset inputLines ;the buffer
	CALL ReadFromFile
	;CALL WriteInt ;view number of bytes read (EAX)
	;CALL CRLF

	;mov EDX, offset inputLines
	;mov ECX, EAX ;EAX = number of bytes read
	;LoopWriteLines:
		;mov AL, [EDX]
		;CALL WriteChar
		;;CALL CRLF
		;add EDX, type inputLines
	;loop LoopWriteLines
ret
ReadLines ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Opens a new text file and opens for input.
; Receives: EDX points to the filename.
; Returns: If the file was opened successfully, EAX
; contains a valid file handle. Otherwise, EAX equals
; INVALID_HANDLE_VALUE.
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenFile PROC
INVOKE CreateFile,
	edx, GENERIC_READ, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
ret
OpenFile ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Converts a list of characters representing integer into their integer values.
; Receives: ESI points to the array of characters, EDI points to
; the array of numbers to fill.
; Returns: EAX containing the total number of the converted numbers.
; Requirements: All the lists must be lists of BYTES.
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ConvertCharsToNumbers PROC USES EBX ECX EDX ESI EDI
	mov ECX, 0	; temporary counter of the integer elements
	mov BL, 0	; temporary value to update with the integer number
	mov EDX, 0	; counter spaces
	while_convertingChars:
		mov AL, [ESI]
		cmp AL, '*'
		JE endwhile_convertingChars	; EOF character
		call IsDigit
		JZ if_updateESIvalue ; contains a valid number
		cmp EDX, 0	; first space after a number
		JNE endif_updateESIvalue

		; AL has the first space or enter, then move the previous integer value in the list
		mov [EDI], BL
		mov BL, 0 ; reset the temporary value
		inc ECX ; count an integer
		inc EDI	; go to the next index
		inc EDX ; count a space
		JMP endif_updateESIvalue

		; BL = (BL * 10) + AL = (result * 10) + digit
		if_updateESIvalue:
			sub AL, '0' ; convert the ASCII character to its digit value
			mov BH, AL	; save the  digit
			mov AL, BL	; needed for MUL
			mov BL, 10	; needed for MUL
			mul BL	; (BL * 10) = (result * 10)
			add AL, BH ; (BL * 10) + BH --having value of AL--
			mov BL, AL ; update the original container
			mov EDX, 0 ; always update the spaces counter to zero
		endif_updateESIvalue:
		inc ESI ; go to the next character
	JMP while_convertingChars
	endwhile_convertingChars:
	mov EAX, ECX
ret
ConvertCharsToNumbers ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Divides a list of points stored as {x, y,x , y, ...} into 2 lists
; Receives: EDX points to array of points, ESI points to
;	array of x-coordinates, EDI points to array of y-coordinates
;	ECX containing number of elements in the array of points
; Returns: EAX containing the total number of the converted numbers.
; Requirements: All the lists must be lists of BYTES.
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DivideIntoXY PROC USES EAX EDX ECX ESI EDI
	loop_xyDivision:
		; Line_i Start_x
		mov AL, [EDX]
		mov [ESI], AL
		inc ESI
		inc EDX
		; Line_i Start_y
		mov AL, [EDX]
		mov [EDI], AL
		inc EDI
		inc EDX
		; Line_i End_x
		mov AL, [EDX]
		mov [ESI], AL
		inc ESI
		inc EDX
		; Line_i End_y
		mov AL, [EDX]
		mov [EDI], AL
		inc EDI
		inc EDX

		;add xNumberElement, 2
		;add yNumberElement, 2
		sub ECX, 3
	LOOP loop_xyDivision
ret
DivideIntoXY ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Divides a number by two
;Receives: EAX: the number to divide (N)
;Returns: EAX: N/2
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DivideByTwo PROC USES EBX EDX
	mov EDX, 0
	mov EBX, 2
	div EBX
ret
DivideByTwo ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FindTriangles PROC
	mov numOfTriangles, 0
	mov numOfBytesTriangles, 0
	mov numOfPointsTriangles, 0
	movzx ECX, numOfLines ;iterating over all lines,
	sub ECX, 2			  ;except last 2 lines (because we need 3 lines to form a trianlge)
	;1st iteration: EAX (index of line 1) = 0
	;2nd iteration: EAX = 2 (because each line us represented with start and end, so 2 bytes)
	;so for each iteration: EAX += 2
	mov EAX, 0	;index of line1 (1st iteration of 1st loop, gets incremented by 2 after each iteration)
	loop_firstLineTri:
		push ECX

		mov EBX, EAX
		add EBX, 2 ;index of line2 = index of line1 + 2
		loop_secondLineTri:
			;check start1 and start2
			;check x's
			mov EDI, offset xList
			add EDI, EAX ;EDI = beginning + index of line1 (EAX)
			mov ESI, offset xList
			add ESI, EBX ;ESI = beginning + index of line2 (EBX)
			cmpsb ;check if both lines have the same start
			JNE checkEnds_FindTri
			;same x, check y's
			mov EDI, offset yList
			add EDI, EAX ;y coordinate of the start of line1, EAX = index of line1
			mov ESI, offset yList
			add ESI, EBX ;y coordiante of the start of line2, EBX = index of line2
			cmpsb
			JNE checkEnds_FindTri
			;the 2 lines have the same start point, so we need to find a line that has the other two end points
			;for the FindThirdLine PROC:
			;EDX = index of line to start checking from
			mov EDX, EBX
			add EDX, 2
			;EAX = index of pt1 (end pt. of line1)
			push EAX ;start pt. of line1
			inc EAX
			;EBX = index of pt2 (end pt. of line2)
			push EBX ;start pt. of line2
			inc EBX ;index of end of pt2
			CALL FindThirdLine_FindTri
			pop EBX
			pop EAX
			;result is returned in EDX
			cmp EDX, -1
			JE nextLine_FindTri
			mov EDI, offset pointsTrianglesList
			add EDI, numOfBytesTriangles
			mov [EDI], EAX ;start of line1 (intersection pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EAX
			add DWORD ptr [EDI], 1 ;end of line1 (2nd pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EBX
			add DWORD ptr [EDI], 1 ;end of line2 (3rd pt.)
			add numOfBytesTriangles, type pointsTrianglesList * 3
			add numOfPointsTriangles, 3
			inc numOfTriangles
			JMP nextLine_FindTri

			checkEnds_FindTri:
			mov EDI, offset xList
			add EDI, EAX ;x coordinate of the start point of line1
			inc EDI ;x coordinate of end point of line1
			mov ESI, offset xList
			add ESI, EBX ;x coordinate of the start point of line2
			inc ESI ;x coordinate of the end point of line2
			cmpsb
			JNE checkCrossStartEnd_FindTri
			mov EDI, offset yList
			add EDI, EAX
			inc EDI ;y coordinate of the end pt. of line1
			mov ESI, offset yList
			add ESI, EBX
			inc ESI ;y coordinate of the end pt. of line2
			cmpsb
			JNE checkCrossStartEnd_FindTri
			;EAX = line1 index
			;EBX = line2 index
			;EDX = EBX + 2 (line3 index, start searching from there)
			push EAX
			push EBX
			mov EDX, EBX
			add EDX, 2
			CALL FindThirdLine_FindTri
			pop EBX
			pop EAX
			cmp EDX, -1
			JE nextLine_FindTri
			mov EDI, offset pointsTrianglesList
			add EDI, numOfBytesTriangles
			mov [EDI], EAX ;start of line1 (1st pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EAX
			add DWORD ptr [EDI], 1 ;end of line1 (intersection pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EBX ;start of line2 (3rd pt.)
			add numOfBytesTriangles, type pointsTrianglesList * 3
			add numOfPointsTriangles, 3
			inc numOfTriangles
			JMP nextLine_FindTri

			checkCrossStartEnd_FindTri: ;check if start of line1 = end of line2
			mov EDI, offset xList
			add EDI, EAX ;x coordinate of the start point of line1
			mov ESI, offset xList
			add ESI, EBX
			inc ESI ;x coordinate of the end point of line2
			cmpsb
			JNE checkCrossEndStart_FindTri
			;same x's, check y's
			mov EDI, offset yList
			add EDI, EAX ;y coordinate of the start point of line1
			mov ESI, offset yList
			add ESI, EBX
			inc ESI ;y coordinate of the end point of line2
			cmpsb
			JNE checkCrossEndStart_FindTri
			;same x, same y (start of line1 = end of line2)
			;for FindThirdLine PROC:
			;EAX = end of line1
			;EBX = start of line2
			;EDX = start of line to start checking from (start of line2 + 2)
			push EAX
			push EBX
			inc EAX
			mov EDX, EBX
			add EDX, 2
			CALL FindThirdLine_FindTri
			pop EBX
			pop EAX
			cmp EDX, -1
			JE nextLine_FindTri
			mov EDI, offset pointsTrianglesList
			add EDI, numOfBytesTriangles
			mov [EDI], EAX ;start of line1 (intersection pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EAX
			add DWORD ptr [EDI], 1 ;end pt. of line1 (2nd pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EBX ;start of line2 (3rd pt.)
			add numOfBytesTriangles, type pointsTrianglesList * 3
			add numOfPointsTriangles, 3
			inc numOfTriangles
			JMP nextLine_FindTri

			checkCrossEndStart_FindTri:
			mov EDI, offset xList
			add EDI, EAX ;x coordinate of the start point of line1
			inc EDI ;x coordinate of the end point of line1
			mov ESI, offset xList
			add ESI, EBX ;x coordinate of the start point of line2
			cmpsb
			JNE nextLine_FindTri
			mov EDI, offset yList
			add EDI, EAX ;y coordinate of the start point of line1
			inc EDI ;y coordinate of the end point of line1
			mov ESI, offset yList
			add ESI, EBX ;y coordinate of the start point of line2
			cmpsb
			JNE nextLine_FindTri
			;end of line1 = start of line2
			;for FindThirdLine PROC:
			;EAX = start of line1
			;EBX = end of line2
			;EDX = start of line to start checking from (starts of line2 + 2)
			push EAX
			push EBX
			mov EDX, EBX
			add EDX, 2
			inc EBX
			CALL FindThirdLine_FindTri
			pop EBX
			pop EAX
			cmp EDX, -1
			JE nextLine_FindTri
			mov EDI, offset pointsTrianglesList
			add EDI, numOfBytesTriangles
			mov [EDI], EBX ;start of line2 (intersection pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EAX ;start of line1 (2nd pt.)
			add EDI, type pointsTrianglesList
			mov [EDI], EBX
			add DWORD ptr [EDI], 1 ;end of line2 (3rd pt.)
			add numOfBytesTriangles, type pointsTrianglesList * 3
			add numOfPointsTriangles, 3
			inc numOfTriangles

			nextLine_FindTri:
			add EBX, 2 ;x coordinate of the start of the next line in 2nd loop

		;LOOP loop_secondLineTri: JUMP TOO FAR, HAS TO BE WRITTEN EXPLICITLY
		dec ECX
		JNZ loop_secondLineTri

		add EAX, 2 ;next line in 1st loop
		pop ECX ;retrieve the original counter of 1st loop from stack

	;LOOP loop_firstLineTri: JUMP TOO FAR, HAS TO BE WRITTEN EXPLICITLY
	dec ECX
	JNZ loop_firstLineTri

	done_FindTri:
ret
FindTriangles ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;After finding two lines intersecting at one point,
;this function searches for the third line that completes the triangle, if it exists,
;i.e. a line whose 2 points are equal to the 2 points in the parameters, order doesn't matter.
;Receives:  EAX contains the index of the 1st point
;			EBX contains the index of the 2nd point
;			EDX contains the index of the line to start checking from
;Returns:	EDX contains the index of the third line if found, else it contains -1
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

FindThirdLine_FindTri PROC USES ECX
		push EAX ;EAX is an input parameter, we need to keep its value
		mov EAX, EDX ;we need to divide the index of the line by 2
		CALL DivideByTwo ;EAX = EDX/2 = index/2
		movzx ECX, numOfLines
		sub ECX, EAX ;loopCounter = numOfLines - # of line to start checking from
					 ;# of the line = index of the line divided by two,
					 ;if index = 8, then it's the 4th line (because each line takes up 2 indices (start and end)
		pop EAX
		loop_FindThirdLine:
			;check start of current line with 1st pt (EDI)
			mov EDI, offset xList
			add EDI, EAX ;x coordinate of 1st pt.
			mov ESI, offset xList
			add ESI, EDX ;x coordinate of current line
			cmpsb
			JNE checkCurrEndWithFirstPt_FindThirdLine
			;same x, check y's
			mov EDI, offset yList
			add EDI, EAX ;y coordinate of 1st pt.
			mov ESI, offset yList
			add ESI, EDX ;y coordinate of current line
			cmpsb
			JNE checkCurrEndWithFirstPt_FindThirdLine
			;same x, same y, check end pt. of current line with 2nd pt.
			JMP checkCurrEndWithSecPt_FindThirdLine

			checkCurrEndWithFirstPt_FindThirdLine:
			;check x's
			mov EDI, offset xList
			add EDI, EAX ;x of 1st pt.
			mov ESI, offset xList
			add ESI, EDX ;x of curr start
			inc ESI ;x of curr end
			cmpsb
			JNE nextLine_FindThirdLine
			;same x, check y's
			mov EDI, offset yList
			add EDI, EAX ;y of 1st pt.
			mov ESI, offset yList
			add ESI, EDX ;y of curr start
			inc ESI ;y of curr end
			cmpsb
			JNE nextLine_FindThirdLine
			;current end = 1st point, then we need to check if current start = 2nd point
			JMP checkCurrStartWithSecPt_FindThirdLine

			checkCurrEndWithSecPt_FindThirdLine:
			mov ESI, offset xList
			add ESI, EBX ;x of 2nd pt.
			mov EDI, offset xList
			add EDI, EDX ;x of curr start
			inc EDI ;x of curr end
			cmpsb
			JNE nextLine_FindThirdLine
			;same x, check y's
			mov ESI, offset yList
			add ESI, EBX ;y of 2nd pt.
			mov EDI, offset yList
			add EDI, EDX ;y of curr start
			inc EDI ;y of curr end
			cmpsb
			JNE nextLine_FindThirdLine
			;FOUND THE LINE (curr start = 1st pt, curr end = 2nd pt)
			JMP foundThirdLine_FindThirdLine

			checkCurrStartWithSecPt_FindThirdLine:
			;check x's
			mov ESI, offset xList
			add ESI, EBX ;x of 2nd pt.
			mov EDI, offset xList
			add EDI, EDX ;x of curr start
			cmpsb
			JNE nextLine_FindThirdLine
			;same x, check y's
			mov ESI, offset yList
			add ESI, EBX ;y of 2nd pt.
			mov EDI, offset yList
			add EDI, EDX ;y of curr start
			cmpsb
			JNE nextLine_FindThirdLine
			;FOUND THE LINE (curr start = 2nd pt, curr end = 1st pt)
			JMP foundThirdLine_FindThirdLine

			nextLine_FindThirdLine:
			add EDX, 2

		;LOOP loop_FindThirdLine: JUMP TOO FAR, HAS TO BE WRITTEN EXPLICITLY
		dec ECX
		JNZ loop_FindThirdLine

		mov EDX, -1 ;third line not found
		
		foundThirdLine_FindThirdLine:
		;return, EDX contains the index of the found third line (hopefully :'D)
ret
FindThirdLine_FindTri ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; findRectanglesAndSquares PROC only calls for the other 2 functions:
; 1- findIntersections which calculates all the intersections
; 2- findRectangles which finds all the rectangles and squares found and returns :
;		1) The Number of Rectangles found in rectanglesNumber
;		2) The Number of Squares found in squaresNumber
;		3) A list with the x-coordinates of the 4 points of each of the found rectangles in the form of
;					(if the rectangle is named ABCD clockwise then it's stored in the form of ADCB { A_x1, D_x1 , C_x1, B_x1, A_x2, D_x2 , C_x2, B_x2, ....}
;		4) A list with the x-coordinates of the 4 points of each of the found Squares in the form of
;					(if the square is named ABCD clockwise it's stored in the form of ADCB { A_x1, D_x1 , C_x1, B_x1, A_x2, D_x2 , C_x2, B_x2, ....}
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

findRectanglesAndSquares PROC

	CALL findIntersections
	CALL findRectangles

	mov EAX, rectanglesNumber
	call writedec
	call crlf
	mov EAX, squaresNumber
	call writedec
	call crlf

ret
findRectanglesAndSquares ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------;
; distinctPoint PROC validates whether or not the found intersection point is distinct "not found and stored before" to prevent having any duplicates in the intersections list.   ;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------;

distinctPoint PROC
	mov isDistinctIntersection, 0
	mov EDX, offset xIntersections
	mov EBX, offset yIntersections
	mov ECX, intersectionsNumber
	cmp ECX, 0
	je if_noIntersections
	loop_traverse:		; this loops through the already saved intersections and compare the new point with the existing ones.
		mov AL, [EDX]   ; the x-coordinate of the existing points.
		cmp AL, x
		je if_equal		; if the current and the new point has the same x-coordinate value.
			jmp endif_equal
		if_equal:
			mov AL, [EBX]	; the y-coordinate of the existing points.
			cmp AL, y		; compare there y-coordinates.
			je if_equall
				jmp endif_equal
			if_equall:
				mov isDistinctIntersection, 1 ; if they're equal in both of their x and y coordinates then the new point is not distinct dont store it.
			endif_equall:
		endif_equal:
		inc EDX
		inc EBX
	LOOP loop_traverse
	if_noIntersections:
	RET
distinctPoint ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; findIntersections PROC traverses through the xList an yList of the given lines to find the intersections and stores them.
; It returns the number of the found intersections in intersectionsNumber and its values in 2 lists:
;	1) xIntersections carrying the x-coordinate values of the intersection points {x1, x2, x3, x4, ....}.
;	2) yIntersections carrying the y-coordinate values of the intersection points {y1, y2, y3, y4, ....}.
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

findIntersections PROC
	mov EDX, offset xList
	mov EBX, offset yList
	mov EDI, offset xIntersections
	mov ESI, offset yIntersections
	movzx ECX, xNumberElement

	loop_firstLine: ; selects a line an to find its intersections with the other lines

		mov xCurOffset1, EDX ;as we use EDX and EBX in the second loop too
		mov yCurOffset1, EBX
		mov tmp1stPointECX, ECX

		; store the current line's values in the variables to use in the second loop
		mov Al, [EDX]
		mov xStCurPoint, AL
		mov Al, [EDX + 1]
		mov xEnCurPoint, AL
		mov Al, [EBX]
		mov yStCurPoint, AL
		mov Al, [EBX + 1]
		mov yEnCurPoint, AL

		add EDX, 2
		add EBX, 2
		dec ECX
		dec ECX
		cmp ECX, 0
		je endloop_findIntersectionWCur

		loop_findIntersectionWCur: ; second loop finds the lines that intersects with the line from the 1st loop and stores the intersection points
			; check if they have the same start x-coordinate.
			mov AL, [EDX]
			cmp AL, xStCurPoint
			je if_sameXSt 

			chkEn: ; check if they have the same end x-coordinate.
			mov AL, [EDX + 1]
			cmp AL, xEnCurPoint
			je if_sameXEn

			chkStEn: ; check if the start x-coordinate of the second line is the same as the end x-coordinate of the first line.
			mov AL, [EDX]
			cmp AL, xEnCurPoint
			je if_sameXStEn
		    
			chkEnSt: ; check if the end x-coordinate of the second line is the same as the start x-coordinate of the first line.
			mov AL, [EDX + 1]
			cmp AL, xStCurPoint
			je if_sameXEnSt
				jmp continueSearching

			if_sameXSt: ; if same start x-coordinate check the y-coordinates for both.
				mov AL, [EBX]
				cmp AL, yStCurPoint
				je if_sameYSt
					jmp chkEn ;else check the rest of the options.
			endif_sameXSt:

			if_sameXEn:	; if same end x-coordinate check the y-coordinates for both.
				mov AL, [EBX + 1]
				cmp AL, yEnCurPoint
				je if_sameYEn
					jmp chkStEn ;else check the rest of the options.
			endis_sameXEn:

			if_sameXStEn: ; if the start x-coordinate of the second line is the same as the end x-coordinate of the first line.
				mov AL, [EBX] 
				cmp AL, yEnCurPoint
				je if_sameYSt
					jmp chkEnSt	;else check the rest of the options.
			endif_sameXStEn:

			if_sameXEnSt: ;if the end x-coordinate of the second line is the same as the start x-coordinate of the first line.
				mov AL, [EBX + 1]
				cmp AL, yStCurPoint
				je if_sameYEn
					jmp continueSearching ;else continue searching through the rest of the lines.	
			endif_sameXEnSt:

			if_sameYSt: ;if they have the same  start y-coordinates store the offsets
				mov xFirstPointOffset, EDX
				mov yFirstPointOffset, EBX
				mov tmpValidatePointECX, ECX

				;store the values of the point in the x and y variables
				mov AL, [EDX]
				mov x, AL
				mov AL, [EBX]
				mov y, AL

				; check if the point is distinct
				CALL distinctPoint

				;restore the original offsets
				mov ECX, tmpValidatePointECX
				mov EDX, xFirstPointOffset
				mov EBX, yFirstPointOffset

				
				mov Al, isDistinctIntersection
				cmp AL, 0
				je if_validPointSt ; the pont is distinct if the variable equales 0 and not if it equals 1
					jmp continueSearching

				if_validPointSt: ; if the point is distinct then it's valid and we should store it
					mov AL, [EDX]
					mov [EDI], AL
					mov AL, [EBX]
					mov [ESI], AL

					; increment EDI and ESI for thenext point found, increment the count of intersections
					inc EDI
					inc ESI
					inc intersectionsNumber
					jmp continueSearching
				endif_validPointSt:
			endif_sameYSt:

			if_sameYEn: ; same operations as if_sameYSt with the diffrence that we store the end point's value not the start 
				mov xFirstPointOffset, EDX
				mov yFirstPointOffset, EBX
				mov tmpValidatePointECX, ECX

				mov AL, [EDX + 1]
				mov x, AL
				mov AL, [EBX + 1]
				mov y, AL

				CALL distinctPoint

				mov ECX, tmpValidatePointECX
				mov EDX, xFirstPointOffset
				mov EBX, yFirstPointOffset

				mov Al, isDistinctIntersection
				cmp AL, 0
				je if_validPointEn
					jmp continueSearching

				if_validPointEn:
					mov AL, [EDX + 1]
					mov [EDI], AL
					mov AL, [EBX + 1]
					mov [ESI], AL
					inc EDI
					inc ESI
					inc intersectionsNumber
				endif_validPointEn:
			endif_sameYEn:

			continueSearching: ; dec EDX and EDI and ECX and continue searching for other intersections with the first line.
			add EDX, 2
			add EBX, 2
			sub ECX, 2
			cmp ECX, 0
			je endloop_findIntersectionWCur
		JMP loop_findIntersectionWCur
		endloop_findIntersectionWCur:
		; restore the first loop's original registers values, dec EDX and EDI and ECX and repeat the operation for the other lines.
		mov EDX, xCurOffset1
		mov EBX, yCurOffset1

		add EDX, 2
		add EBX, 2
		mov ECX, tmp1stPointECX
		sub ECX, 2
		cmp ECX, 0
		jbe endloop_firstLine
	JMP loop_firstLine
	endloop_firstLine:

ret
findIntersections ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; checkSquare PROC checks if the found 4 points form a rectangle or a square and stores them in there respective Lists.
; the 4 points are in the anti-clockwise order like this A = ( x1 , y1 ) -> D = ( x1 , y2 ) -> C = ( x3 , y2 ) -> B = ( x3 , y1 ).
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

checkSquare PROC
	; if abs( y2 - y1 ) == abs( x3 - x1 ) then the four points form a square

	; abs ( y2 - y1 )
	mov AL, y2
	cmp AL, y1
	ja if_neg1 ; if y2 > y1
		mov AL, y1
		sub AL, y2
		jmp endif_neg1 ; if y1 > y2

	if_neg1:
		sub AL, y1
	endif_neg1:

	; abs ( x3 - x1 )
	mov x, AL
	mov AL, x1
	cmp AL, x3
	ja if_neg2  ; if x1 > x3
		mov Al, x3
		sub AL, x1
		jmp endif_neg2  ; if x3 > x1

	if_neg2:
		sub AL, x3
	endif_neg2:

	cmp Al, x
	je if_square
		jmp if_Rectangle

	if_Square: ; if the 4 points form a Square fitch the xSquaresList and the ySquaresList offsets and store the points in the mentioned order.
		mov EDI, xSquaresOffset
		mov ESI, ySquaresOffset

		mov Al, x1
		mov [EDI], AL
		mov AL, y1
		mov [ESI], AL
		inc EDI
		inc ESI

		mov Al, x2
		mov [EDI], AL
		mov AL, y2
		mov [ESI], AL
		inc EDI
		inc ESI

		mov Al, x3
		mov [EDI], AL
		mov AL, y3
		mov [ESI], AL
		inc EDI
		inc ESI
		
		mov Al, x4
		mov [EDI], AL
		mov AL, y4
		mov [ESI], AL
		inc EDI
		inc ESI

		mov xSquaresOffset, EDI
		mov ySquaresOffset, ESI
		inc SquaresNumber
		jmp endif_Rectangle
	endif_Square:

	if_Rectangle:; if the 4 points form a rectangle fitch the xRectanglesList and the yRectanglesList offsets and store the points in the mentioned order.
		mov EDI, xRectanglesOffset
		mov ESI, yRectanglesOffset

		mov Al, x1
		mov [EDI], AL
		mov AL, y1
		mov [ESI], AL
		inc EDI
		inc ESI

		mov Al, x2
		mov [EDI], AL
		mov AL, y2
		mov [ESI], AL
		inc EDI
		inc ESI

		mov Al, x3
		mov [EDI], AL
		mov AL, y3
		mov [ESI], AL
		inc EDI
		inc ESI
		
		mov Al, x4
		mov [EDI], AL
		mov AL, y4
		mov [ESI], AL
		inc EDI
		inc ESI

		mov xRectanglesOffset, EDI
		mov yRectanglesOffset, ESI
		inc rectanglesNumber
	endif_Rectangle:
	RET
checkSquare ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;findRectangles PROC uses 4 nested points to find all possible 4 points that can form a rectangle or a square 
;	by insureing that every 2 points are in fact the end and start of an already existing line.
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

findRectangles PROC

	mov EDX, offset xIntersections
	mov EBX, offset yIntersections
	mov xRectanglesOffset, offset xRectanglesList
	mov yRectanglesOffset, offset yRectanglesList
	mov xSquaresOffset, offset xSquaresList
	mov ySquaresOffset, offset ySquaresList
	mov ECX, intersectionsNumber

	loop_firstPoint: ; choses a point to stand as point A in the rectangle.
		
		; store the point's values in the respecting variables.
		mov AL, [EDX]
		mov x1, AL
		mov AL, [EBX]
		mov y1, AL

		; temproarly store the values of the registers in variables to reuse them in the second loop.
		mov tmp1stPointECX, ECX
		mov xFirstPointOffset, EDX
		mov yFirstPointOffset, EBX
		
		inc EDX
		inc EBX
		dec ECX
		cmp ECX, 0
		je continue
		loop_secondPoint: ; choses a point to stand as point D in the rectangle.

			; temproarly store the values of the registers in variables to reuse them in the third loop.
			mov xSecondPointOffset, EDX
			mov ySecondPointOffset, EBX
			mov tmp2ndPointECX, ECX

			; find the second point D by searching for a point with the values of (x1, y2 ).
			mov AL, x1
			cmp AL, [EDX]
			je if_sameX1
				jmp continue2

			if_sameX1:	
				mov AL, y1
				cmp AL, [EBX]
				je endif_sameX1 ; if the point hase the same x-coordinate and a different y-coordinate then we can consider it a possible D point.

				; store the point's values in the respecting variables.
				mov AL, [EDX]
				mov x2, AL
				mov AL, [EBX]
				mov y2, AL
				mov tmp2ndPointECX, ECX
				
				inc EDX
				inc EBX
				dec ECX
				cmp ECX, 0
				je continue2
				loop_thirdPoint: ; choses a point to stand as point C in the rectangle.

					; temproarly store the values of the registers in variables to reuse them in the fourth loop.
					mov xThirdPointOffset, EDX
					mov yThirdPointOffset, EBX
					mov tmp3rdPointECX, ECX

					; find the Third point D by searching for a point with the values of ( x3 , y2 ).
					mov AL, y2
					cmp AL, [EBX]
					je if_sameY2
						jmp continue3

					if_sameY2:
						mov AL, x2
						cmp AL, [EDX]
						je endif_sameY2 ; if the point hase the same x-coordinate and a different y-coordinate then we can consider it a possible D point.
						
						; store the point's values in the respecting variables.
						mov AL, [EDX]
						mov x3, AL
						mov AL, [EBX]
						mov y3, AL

						; in this loop we start searching from the start of the intersection list to insure that we find all possible rectanglesanlike the above three loops.
						mov tmp3rdPointECX, ECX
						mov ECX, intersectionsnumber
						mov EDX, offset xintersections
						mov EBX, offset yintersections
						
						loop_fourthPoint: ; choses a point to stand as point B in the rectangle.

							; insure that am not looking at any of the first 3 points.
							mov tmp4thPointECX, ECX
							cmp EDX, xFirstPointOffset
							je continue4
							cmp EDX, xSecondPointOffset
							je continue4
							cmp EDX, xThirdPointOffset
							je continue4

							; find the Third point B by searching for a point with the values of ( x3 , y1 ).
							mov AL, x3
							cmp AL, [EDX] ; check if it has the x3 coordinate
							je if_sameX3
								jmp continue4

							if_sameX3:
								mov AL, y1 
								cmp AL, [EBX] ; check if it has the y1 coordinate
								je if_sameY1  
									jmp continue4

									if_sameY1:
										
										; store the point's values in the respecting variables.
										mov AL, [EDX]
										mov x4, AL
										mov AL, [EBX]
										mov y4, AL

										; validate that each 2 points of the chosen 4 points has an already existing line between them.
										validateCurRec:
											mov validRec, 0 ; if equals 4 then there's 4 lines inbetween which is right.

											mov tmpValidateRecECX, ECX
											mov EDI, offset xList
											mov ESI, offset yList
											movzx ECX, xNumberElement

											loop_findLines: ; traverses the given lines through the xList and yList to find the required lines.

											chk1stLine: ; check if there exists a line between point A and D.

												; the variable x will serve as the start x-coordinate of the line AD.
												; the variable y will serve as the start y-coordinate of the line AD.
												mov AL, x1
												mov x, Al
												mov AL, y1
												mov y, AL

												; the variable x5 will serve as the end x-coordinate of the line AD.
												; the variable y5 will serve as the end y-coordinate of the line AD.
												mov AL, x1
												mov x5, Al
												mov AL, y2
												mov y5, AL

												mov line, 1 ; mark that I'm checking for the 1st line.
												jmp checkLine
											endchk1stLine:

											chk2ndLine: ; check if there exists a line between point D and C.
												
												; the variable x5 will serve as the start x-coordinate of the line DC.
												; the variable y5 will serve as the start y-coordinate of the line DC.
												mov AL, x1
												mov x, Al
												mov AL, y1
												mov y, AL

												; the variable x5 will serve as the end x-coordinate of the line DC.
												; the variable y5 will serve as the end y-coordinate of the line DC.
												mov AL, x3
												mov x5, Al
												mov AL, y1
												mov y5, AL

												mov line, 2 ; mark that I'm checking for the 2nd line.
												jmp checkLine
											endchk2ndLine:

											chk3rdLine: ; check if there exists a line between point B and C.

												; the variable x5 will serve as the start x-coordinate of the line BC.
												; the variable y5 will serve as the start y-coordinate of the line BC.
												mov AL, x3
												mov x, Al
												mov AL, y1
												mov y, AL

												; the variable x5 will serve as the end x-coordinate of the line BC.
												; the variable y5 will serve as the end y-coordinate of the line BC.
												mov AL, x3
												mov x5, Al
												mov AL, y2
												mov y5, AL

												mov line, 3 ; mark that I'm checking for the 3rd line.
												jmp checkLine
											endchk3rdLine:

											chk4thLine: ; check if there exists a line between point A and B.

												; the variable x5 will serve as the start x-coordinate of the line AB.
												; the variable y5 will serve as the start y-coordinate of the line AB.
												mov AL, x1
												mov x, Al
												mov AL, y2
												mov y, AL

												; the variable x5 will serve as the end x-coordinate of the line AB.
												; the variable y5 will serve as the end y-coordinate of the line AB.
												mov AL, x3
												mov x5, Al
												mov AL, y2
												mov y5, AL

												mov line, 4 ; mark that I'm checking for the 4th line.
												jmp checkLine
											endchk4thLine:

											checkLine: ; checks if the current line is the required line or not.
		
												mov AL, [EDI]
												cmp Al, x
												je if_equalXSt ;if the line's start x-coordinate equals the required line's start x-coordinate.

													elseNot: 
													mov AL, [EDI]
													cmp Al, x5
													je if_equalX5St ;if the line's start x-coordinate equals the required line's end x-coordinate.
														jmp endcheckLine

												if_equalXSt: 
													mov AL, [ESI]
													cmp Al, y
													je if_equalYSt 
														jmp elseNot ; else check the stsrt end case.

													if_equalYSt: ;if the line's start y-coordinate equals the required line's start y-coordinate.
														mov AL, [EDI + 1]
														cmp AL, x5
														je if_equalX5En
															jmp endcheckLine ; else then that's not the required line.

														if_equalX5En: ;if the line's end x-coordinate equals the required line's end x-coordinate.
															mov AL, [ESI + 1]
															cmp Al, y5
															je if_equalY5En
																jmp endcheckLine ; else then that's not the required line.

															if_equalY5En: ;if the line's end y-coordinate equals the required line's end y-coordinate.

																inc validRec ; then thats the required line and we increment the counter validRec.

															endif_equalY5En:

														endif_equalX5En:

													endif_equalYSt:

												endif_equalXSt:

												if_equalX5St: ;if the line's start x-coordinate equals the required line's end x-coordinate.
													mov AL, [ESI]
													cmp Al, y5
													je if_equalY5St
														jmp endcheckLine ; else then that's not the required line.

													if_equalY5St: ;if the line's start y-coordinate equals the required line's end y-coordinate.
														mov AL, [EDI + 1]
														cmp AL, x
														je if_equalXEn
															jmp endcheckLine ; else then that's not the required line.

														if_equalXEn: ;if the line's end x-coordinate equals the required line's start x-coordinate.
															mov AL, [ESI + 1]
															cmp Al, y
															je if_equalYEn
																jmp endcheckLine ; else then that's not the required line.

															if_equalYEn: ;if the line's end x-coordinate equals the required line's start x-coordinate.

																inc validRec

															endif_equalYEn:

														endif_equalXEn:

													endif_equalY5St:

												endif_equalX5St:
												
											endcheckLine:

											; check which line I was checking for to go back and check for the rest.
											mov AL, line
											cmp AL, 1
											je chk2ndLine
												cmp AL, 2
												je chk3rdLine
													cmp AL, 3
													je chk4thLine

											continuechk:
												add EDI, 2
												add ESI, 2
												sub ECX, 2
												cmp ECX, 0
												je endloop_findLines
											jmp loop_findLines
											endloop_findLines:
											mov ECX, tmpValidateRecECX
										endvalidateCurRec:

										; check if the counter validRec's value is 4, then we have a valid potential rectangle or square.
										cmp validRec, 4
										jb endif_sameY1

										CALL checkSquare ; check to see if the shape I found is a rectangle or a square and store it in the crossponding lists.

									endif_sameY1:

							endif_sameX3:
			
							continue4:
							inc EDX
							inc EBX
							dec ECX
							cmp ECX, 0
							je endif_sameY2
						jmp loop_fourthPoint

					endif_sameY2:
			
					continue3:
					mov EDX, xThirdPointOffset
					mov EBX, yThirdPointOffset
					mov ECX, tmp3rdPointECX
					inc EDX
					inc EBX
					dec ECX
					cmp ECX, 0
					je endif_sameX1
				jmp loop_thirdPoint

			endif_sameX1:
			
			continue2:
			mov EDX, xSecondPointOffset
			mov EBX, ySecondPointOffset
			mov ECX, tmp2ndPointECX
			inc EDX
			inc EBX
			dec ECX
			cmp ECX, 0
			je continue
		jmp loop_secondPoint

		continue:
		mov EDX, xFirstPointOffset
		mov EBX, yFirstPointOffset
		mov ECX, tmp1stPointECX
		inc EDX
		inc EBX
		dec ECX
		cmp ECX, 0
		je endloop_firstPoint
	jmp loop_firstPoint
	endloop_firstPoint:
	ret
findRectangles ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

END main
;================================================================================================================================================================================================================================================
