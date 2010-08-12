DECLARE SUB WelcomeScreen ()
DECLARE SUB ReadGirlDat (file AS STRING, i AS INTEGER)
DECLARE SUB EnemyMoves ()
DECLARE SUB BugFix ()
DECLARE SUB Prnt (a$, X AS INTEGER, Y AS INTEGER, col!)
DECLARE SUB CalcEvent ()
DECLARE SUB ChangeMap ()
DECLARE FUNCTION Collision! ()
DECLARE SUB DrawFight ()
DECLARE SUB DrawFightBG ()
DECLARE SUB DrawFightLayer ()
DECLARE SUB DrawMap ()
DECLARE SUB DrawMapBG ()
DECLARE SUB DrawMapLayer ()
DECLARE SUB InitFight ()
DECLARE SUB InitStart ()
DECLARE SUB LoadGFX (file AS STRING, gfx() AS INTEGER)
DECLARE SUB MovePlayer ()
DECLARE SUB PutGFX (X AS INTEGER, Y AS INTEGER, gfx() AS INTEGER)
DECLARE SUB ReadMapDat (file AS STRING)
DECLARE SUB SelectFight ()
DECLARE SUB SetPalette1 ()
DECLARE SUB ShowGFX ()
DECLARE SUB UpdatePaletteGradient ()
DECLARE SUB MoveCursor (dir AS STRING)
DECLARE SUB FightSelect ()
DECLARE SUB ShowText ()


'Version: 08.410
'Programmer: Sour Swinger
'Graphics: Jessie Hromiko
'Web Site: blog.sourswinger.name
'Contact: soursw@gmail.com
'Donations appreciated.  Please contact if interested.

TYPE ColorType
	custom AS INTEGER
	grey AS INTEGER
	red AS INTEGER
	orange AS INTEGER
	brown AS INTEGER
	yellow AS INTEGER
	chartruese AS INTEGER
	green AS INTEGER
	springGreen AS INTEGER
	cyan AS INTEGER
	azure AS INTEGER
	blue AS INTEGER
	purple AS INTEGER
	magenta AS INTEGER
	fuchsia AS INTEGER
	gradient AS INTEGER
	blink AS INTEGER
	reserved AS INTEGER
END TYPE

TYPE EnemyType
	at AS INTEGER
	de AS INTEGER
	exist AS INTEGER
	exp AS INTEGER
	hit AS INTEGER
	hp AS INTEGER
	max AS INTEGER
	name AS STRING * 8
	rand AS INTEGER
	X AS INTEGER
	Y AS INTEGER
END TYPE

TYPE FightType
	battle AS INTEGER
	curArea AS INTEGER
	curEnemy AS INTEGER
	curPlayer AS INTEGER
	curX AS INTEGER
	curY AS INTEGER
	damage AS INTEGER
	def AS INTEGER
	numEnemy AS INTEGER
	rand AS INTEGER
	turn AS INTEGER
END TYPE

TYPE FrameType
	cAS AS SINGLE   'Comp Anim Start
	hTS AS SINGLE   'Hit Text Start
	hTD AS SINGLE   'Hit Text Delay
	fRS AS SINGLE   'Frames Rate Start
	fPS AS SINGLE   'Frames Per Second
END TYPE

TYPE IOType
	deff AS STRING * 8
	gfx AS STRING * 4
	key AS INTEGER
	maps AS STRING * 5
	sprite AS STRING * 8
	tiles AS STRING * 6
END TYPE

TYPE MapType
	gfx AS INTEGER
	con1 AS INTEGER
	con2 AS INTEGER
	con3 AS INTEGER
	con4 AS INTEGER
	x1 AS INTEGER
	y1 AS INTEGER
	x2 AS INTEGER
	y2 AS INTEGER
	x3 AS INTEGER
	y3 AS INTEGER
	x4 AS INTEGER
	y4 AS INTEGER
END TYPE

TYPE PlayerType
	at AS INTEGER
	de AS INTEGER
	deb AS INTEGER
	dead AS INTEGER
	exp AS INTEGER
	fightX AS INTEGER
	fightY AS INTEGER
	hit AS INTEGER
	hp AS INTEGER
	level AS INTEGER
	maxHP AS INTEGER
	mapX AS INTEGER
	mapY AS INTEGER
	next AS INTEGER
	rand AS INTEGER
	ready AS INTEGER
END TYPE

'Width * Height + 1
CONST c16x16 = 129
CONST c20x18 = 361
CONST c64x32 = 2049
REM $DYNAMIC
DIM SHARED scr(32001) AS INTEGER

DIM SHARED Cursor(c16x16) AS INTEGER
DIM SHARED diag(c64x32) AS INTEGER

REDIM SHARED city(c16x16) AS INTEGER
REDIM SHARED mtn(c16x16) AS INTEGER
REDIM SHARED tree(c16x16) AS INTEGER
REDIM SHARED water(c16x16) AS INTEGER
REDIM SHARED desert(c16x16) AS INTEGER
REDIM SHARED plains(c16x16) AS INTEGER
REDIM SHARED path(c16x16) AS INTEGER
REDIM SHARED beach(c16x16) AS INTEGER

DIM SHARED map(c20x18) AS INTEGER
DIM SHARED obj(c20x18) AS INTEGER

DIM SHARED enemy1(c16x16) AS INTEGER
DIM SHARED enemy2(c16x16) AS INTEGER
DIM SHARED enemy3(c16x16) AS INTEGER
DIM SHARED enemy4(c16x16) AS INTEGER
DIM SHARED player1(c16x16) AS INTEGER
DIM SHARED player2(c16x16) AS INTEGER

REM $STATIC
DIM SHARED colour AS ColorType
DIM SHARED enemy(4) AS EnemyType
DIM SHARED file AS IOType
DIM SHARED fight AS FightType
DIM SHARED mapInfo AS MapType
DIM SHARED player(2) AS PlayerType

DIM SHARED pal(255) AS LONG
DIM SHARED rate AS FrameType
DIM SHARED in AS STRING

SCREEN 13
RANDOMIZE TIMER

CALL SetPalette1
CALL InitStart
CALL WelcomeScreen

DO
	IF fight.battle = 1 THEN
		CALL BugFix

		IF fight.turn = 0 THEN
			CALL EnemyMoves
		ELSE
			in = INKEY$
			CALL SelectFight
		END IF

		CALL DrawFightBG
		CALL DrawFight
		CALL DrawFightLayer

	ELSE
		DEF SEG = &H40
		POKE &H1A, PEEK(&H1A + 2)
		DEF SEG

		CALL MovePlayer
		CALL DrawMapBG
		CALL DrawMap
		CALL DrawMapLayer
	END IF
	   
	IF (TIMER - rate.fRS > rate.fPS) THEN
		CALL UpdatePaletteGradient
		CALL ShowGFX
		CALL ShowText
		rate.fRS = TIMER
	END IF
LOOP UNTIL INP(&H60) = 1

SUB BugFix
	'FUCKING  QBASIC!!!!!!

	enemy(1).X = 3 * 16
	enemy(1).Y = 6 * 16
	enemy(2).X = 5 * 16
	enemy(2).Y = 6 * 16
	enemy(3).X = 3 * 16
	enemy(3).Y = 8 * 16
	enemy(4).X = 5 * 16
	enemy(4).Y = 8 * 16
	player(1).fightX = 15 * 16
	player(1).fightY = 6 * 16
	player(2).fightX = 15 * 16
	player(2).fightY = 8 * 16


END SUB

SUB CalcEvent
	DIM value AS INTEGER

	with = obj(0) \ 8
	DEF SEG = VARSEG(obj(0))
	value = PEEK(VARPTR(obj(2)) + player(1).mapX \ 16 + with * player(1).mapY \ 16)
	DEF SEG

	SELECT CASE value
		CASE colour.cyan
			mapInfo.gfx = mapInfo.con1
			player(1).mapX = mapInfo.x1 * 16
			player(1).mapY = mapInfo.y1 * 16

		CASE colour.cyan + 1
			mapInfo.gfx = mapInfo.con2
			player(1).mapX = mapInfo.x2 * 16
			player(1).mapY = mapInfo.y2 * 16

		CASE colour.cyan + 2
			mapInfo.gfx = mapInfo.con3
			player(1).mapX = mapInfo.x3 * 16
			player(1).mapY = mapInfo.y3 * 16

		CASE colour.cyan + 3
			CLS
			PRINT "James Gets High...School"
			PRINT
			IF player(1).next < player(1).exp THEN
				PRINT "You gained a fat stash!"
				PRINT "All stats increased"
				player(1).level = player(1).level + 1
				IF player(1).level > 17 THEN
				      CLS
				      PRINT "You attained 17 stashes.  You win!!!"
				END IF
				player(1).next = player(1).next * 2 + (INT(RND * player(1).rand) + 1)
				player(1).maxHP = player(1).maxHP + (INT(RND * player(1).rand) + 1)
				player(1).at = player(1).at + (INT(RND * player(1).rand) + 1)
				player(1).de = player(1).de + (INT(RND * player(1).rand) + 1)
				player(1).rand = player(1).rand + (INT(RND * player(1).rand) + 1)
				player(2).maxHP = player(2).maxHP + (INT(RND * player(2).rand) + 1)
				player(2).at = player(2).at + (INT(RND * player(2).rand) + 1)
				player(2).de = player(2).de + (INT(RND * player(2).rand) + 1)
				player(2).rand = player(2).rand + (INT(RND * player(2).rand) + 1)

			END IF

			player(1).hp = player(1).maxHP
			player(2).hp = player(2).maxHP
			PRINT "You got laid by the local honeys."
			PRINT "Health restored!"
			PRINT
			PRINT "Ignognikt"
			PRINT "Health: " + STR$(player(1).hp)
			PRINT "Attack: " + STR$(player(1).at)
			PRINT "Defense: " + STR$(player(1).de)
			PRINT
			PRINT "Err"
			PRINT "Health: " + STR$(player(2).hp)
			PRINT "Attack: " + STR$(player(2).at)
			PRINT "Defense: " + STR$(player(2).de)
			PRINT
			PRINT "Ounces of Pot: " + STR$(player(1).exp)
			PRINT "Fat Stashes: " + STR$(player(1).level)
			PRINT "Pot Till Stash: " + STR$(player(1).next)
			PRINT
			PRINT "Press any key to continue"
			SLEEP
		CASE ELSE
			EXIT SUB
	END SELECT

	CALL ChangeMap
END SUB

SUB ChangeMap
	SELECT CASE mapInfo.gfx
		CASE 1
			CALL LoadGFX(file.maps + "def.map", map())
			CALL LoadGFX(file.maps + "def.obj", obj())
			CALL ReadMapDat(file.maps + "def.dat")
		CASE 2
			CALL LoadGFX(file.maps + "def1.map", map())
			CALL LoadGFX(file.maps + "def1.obj", obj())
			CALL ReadMapDat(file.maps + "def1.dat")

		CASE ELSE
			PRINT mapInfo.gfx; "Invalid map number"
			SLEEP
			END
	END SELECT

END SUB

FUNCTION Collision
	DIM value AS INTEGER

	'Required. Fixes some memory bug? Fuck if I know why it occurs
	with = obj(0) \ 8

	DEF SEG = VARSEG(obj(0))
	value = PEEK(VARPTR(obj(2)) + player(1).mapX \ 16 + with * player(1).mapY \ 16)
	DEF SEG
       
	IF value = colour.red THEN
		Collision = 1
	ELSE
		Collision = 0
	END IF

END FUNCTION

SUB DrawFight
	

	IF enemy(1).exist > 0 THEN PutGFX enemy(1).X, enemy(1).Y, enemy1()
	IF enemy(2).exist > 0 THEN PutGFX enemy(2).X, enemy(2).Y, enemy2()
	IF enemy(3).exist > 0 THEN PutGFX enemy(3).X, enemy(3).Y, enemy3()
	IF enemy(4).exist > 0 THEN PutGFX enemy(4).X, enemy(4).Y, enemy4()

	IF player(1).dead = 0 THEN PutGFX player(1).fightX, player(1).fightY, player1()
	IF player(2).dead = 0 THEN PutGFX player(2).fightX, player(2).fightY, player2()
	
	PutGFX 48, 150, diag()
	PutGFX 128, 150, diag()
	PutGFX 208, 150, diag()

END SUB

SUB DrawFightBG
	DIM col AS INTEGER
	DIM with AS INTEGER

	with = scr(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO 191
			IF j < 80 THEN
				IF fight.turn = 1 THEN
					col = colour.blue + j \ 6
				ELSE
					col = colour.grey + j \ 6
				END IF
			ELSE
				IF fight.turn = 1 THEN
					col = colour.green + 10
				ELSE
					col = colour.green + 12
				END IF
			END IF

			DEF SEG = VARSEG(scr(0))
			POKE VARPTR(scr(2)) + i + 320& * j, col
			DEF SEG
		NEXT j
	NEXT i

END SUB

SUB DrawFightLayer
	PutGFX fight.curX, fight.curY, Cursor()
END SUB

SUB DrawMap
	DIM i AS INTEGER
	DIM j AS INTEGER
	DIM tile AS INTEGER
	DIM with AS INTEGER
	
	with = map(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO map(1) - 1
			DEF SEG = VARSEG(map(0))
			tile = PEEK(VARPTR(map(2)) + i + with * j)
			DEF SEG

			SELECT CASE tile
				CASE 0
					'transparent

				CASE colour.red
					CALL LoadGFX(file.tiles + "plains\" + "plains1.gfx", plains())
					PutGFX i * 16, j * 16, plains()
				CASE colour.red + 1
					CALL LoadGFX(file.tiles + "plains\" + "plains2.gfx", plains())
					PutGFX i * 16, j * 16, plains()
				CASE colour.red + 2
					CALL LoadGFX(file.tiles + "plains\" + "plains3.gfx", plains())
					PutGFX i * 16, j * 16, plains()
				CASE colour.red + 3
					CALL LoadGFX(file.tiles + "plains\" + "plains4.gfx", plains())
					PutGFX i * 16, j * 16, plains()

				CASE colour.cyan
					CALL LoadGFX(file.tiles + "beach\" + "beach1.gfx", beach())
					PutGFX i * 16, j * 16, beach()
				CASE colour.cyan + 1
					CALL LoadGFX(file.tiles + "beach\" + "beach2.gfx", beach())
					PutGFX i * 16, j * 16, beach()
				CASE colour.cyan + 2
					CALL LoadGFX(file.tiles + "beach\" + "beach3.gfx", beach())
					PutGFX i * 16, j * 16, beach()
				CASE colour.cyan + 3
					CALL LoadGFX(file.tiles + "beach\" + "beach4.gfx", beach())
					PutGFX i * 16, j * 16, beach()
				CASE colour.cyan + 4
					CALL LoadGFX(file.tiles + "beach\" + "beach5.gfx", beach())
					PutGFX i * 16, j * 16, beach()
				CASE colour.cyan + 5
					CALL LoadGFX(file.tiles + "beach\" + "beach6.gfx", beach())
					PutGFX i * 16, j * 16, beach()
				CASE colour.cyan + 6
					CALL LoadGFX(file.tiles + "beach\" + "beach7.gfx", beach())
					PutGFX i * 16, j * 16, beach()

				CASE colour.blue
					CALL LoadGFX(file.tiles + "water\" + "water1.gfx", water())
					PutGFX i * 16, j * 16, water()
				CASE colour.blue + 1
					CALL LoadGFX(file.tiles + "water\" + "water2.gfx", water())
					PutGFX i * 16, j * 16, water()
				CASE colour.blue + 2
					CALL LoadGFX(file.tiles + "water\" + "water3.gfx", water())
					PutGFX i * 16, j * 16, water()
				CASE colour.blue + 3
					CALL LoadGFX(file.tiles + "water\" + "water4.gfx", water())
					PutGFX i * 16, j * 16, water()
				CASE colour.blue + 4
					CALL LoadGFX(file.tiles + "water\" + "water5.gfx", water())
					PutGFX i * 16, j * 16, water()
				CASE colour.blue + 5
					CALL LoadGFX(file.tiles + "water\" + "water6.gfx", water())
					PutGFX i * 16, j * 16, water()

				CASE colour.brown
					CALL LoadGFX(file.tiles + "mtn\" + "mount1.gfx", mtn())
					PutGFX i * 16, j * 16, mtn()
				CASE colour.brown + 1
					CALL LoadGFX(file.tiles + "mtn\" + "mount2.gfx", mtn())
					PutGFX i * 16, j * 16, mtn()
				CASE colour.brown + 2
					CALL LoadGFX(file.tiles + "mtn\" + "mount3.gfx", mtn())
					PutGFX i * 16, j * 16, mtn()
				CASE colour.brown + 3
					CALL LoadGFX(file.tiles + "mtn\" + "mount4.gfx", mtn())
					PutGFX i * 16, j * 16, mtn()
				CASE colour.brown + 4
					CALL LoadGFX(file.tiles + "mtn\" + "mount5.gfx", mtn())
					PutGFX i * 16, j * 16, mtn()
					
				CASE colour.green
					CALL LoadGFX(file.tiles + "tree\" + "tree1.gfx", tree())
					PutGFX i * 16, j * 16, tree()
				CASE colour.green + 1
					CALL LoadGFX(file.tiles + "tree\" + "tree2.gfx", tree())
					PutGFX i * 16, j * 16, tree()
				CASE colour.green + 2
					CALL LoadGFX(file.tiles + "tree\" + "tree3.gfx", tree())
					PutGFX i * 16, j * 16, tree()
				CASE colour.green + 3
					CALL LoadGFX(file.tiles + "tree\" + "tree4.gfx", tree())
					PutGFX i * 16, j * 16, tree()
				CASE colour.green + 4
					CALL LoadGFX(file.tiles + "tree\" + "tree5.gfx", tree())
					PutGFX i * 16, j * 16, tree()
				CASE colour.green + 5
					CALL LoadGFX(file.tiles + "tree\" + "tree6.gfx", tree())
					PutGFX i * 16, j * 16, tree()

				CASE colour.orange
					CALL LoadGFX(file.tiles + "desert\" + "desert1.gfx", desert())
					PutGFX i * 16, j * 16, desert()
				CASE colour.orange + 1
					CALL LoadGFX(file.tiles + "desert\" + "desert2.gfx", desert())

					PutGFX i * 16, j * 16, desert()
				CASE colour.orange + 2
					CALL LoadGFX(file.tiles + "desert\" + "desert3.gfx", desert())
					PutGFX i * 16, j * 16, desert()

				CASE colour.fuchsia
					CALL LoadGFX(file.tiles + "path\" + "path1.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 1
					CALL LoadGFX(file.tiles + "path\" + "path2.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 2
					CALL LoadGFX(file.tiles + "path\" + "path3.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 3
					CALL LoadGFX(file.tiles + "path\" + "path4.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 4
					CALL LoadGFX(file.tiles + "path\" + "path5.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 5
					CALL LoadGFX(file.tiles + "path\" + "path6.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 6
					CALL LoadGFX(file.tiles + "path\" + "path7.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 7
					CALL LoadGFX(file.tiles + "path\" + "path8.gfx", path())
					PutGFX i * 16, j * 16, path()
				CASE colour.fuchsia + 8
					CALL LoadGFX(file.tiles + "path\" + "path9.gfx", path())
					PutGFX i * 16, j * 16, path()

				CASE ELSE
					CALL LoadGFX(file.deff + "impass.gfx", path())
					PutGFX i * 16, j * 16, path()
					
			END SELECT
		NEXT j
	NEXT i

END SUB

SUB DrawMapBG

END SUB

SUB DrawMapLayer
	DIM i AS INTEGER
	DIM j AS INTEGER
	DIM tile AS INTEGER
	DIM with AS INTEGER

	with = obj(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO obj(1) - 1
			DEF SEG = VARSEG(obj(0))
			tile = PEEK(VARPTR(obj(2)) + i + with * j)
			DEF SEG

			SELECT CASE tile
				CASE colour.cyan + 3
					PutGFX i * 16, j * 16, city()
					i = with + 1
					j = obj(1) + 1
			END SELECT
		NEXT j
	NEXT i


	PutGFX player(1).mapX, player(1).mapY, player1()


END SUB

SUB EnemyMoves
	DIM d AS INTEGER
	DIM e AS INTEGER

	STATIC i AS INTEGER
	STATIC p AS INTEGER
			
	IF i = 0 THEN i = 1
	fight.curArea = 5
	IF i <= 4 THEN
	IF enemy(i).exist > 0 THEN
		SELECT CASE TIMER - rate.cAS
			CASE IS > 2
				IF fight.def = 1 THEN
					d = enemy(i).at + INT(RND * enemy(e).rand) - (player(p).de * 2) - INT(RND * player(p).rand)
				ELSE
					d = enemy(i).at + INT(RND * enemy(e).rand) - player(p).de - INT(RND * player(p).rand)
				END IF

				IF (d > 0) THEN
					fight.damage = d
					player(p).hit = 1
					player(p).hp = player(p).hp - d
					IF player(p).hp < 1 THEN
						player(p).dead = 1
						FOR d = 1 TO 2
							IF player(d).dead = 0 THEN
								e = 1
								EXIT FOR
							ELSE
								e = -1
							END IF
						NEXT d
						IF e = -1 THEN
							CLS
							PRINT "YOU DIED!!!"
							SLEEP
							END
						END IF
					END IF
				ELSE
					player(p).hit = 2
				END IF
				rate.hTS = TIMER
				i = i + 1
				rate.cAS = TIMER
			CASE IS > 1
				fight.curX = player(p).fightX
				fight.curY = player(p).fightY

			CASE ELSE
				fight.curX = enemy(i).X
				fight.curY = enemy(i).Y
				DO
					p = INT(RND * 2) + 1
				LOOP UNTIL player(p).dead = 0
		END SELECT
	ELSE
		rate.hTS = TIMER
		i = i + 1
		rate.cAS = TIMER
	END IF
	END IF
	IF i > 4 AND TIMER - rate.hTS > rate.hTD THEN
		i = 0
		fight.turn = 1
		player(1).deb = 0
		player(2).deb = 0
		player(1).ready = 1
		player(2).ready = 1
		fight.curArea = 1
		fight.curX = 140
		fight.curY = 150
		CALL LoadGFX(file.gfx + "cursor1.gfx", Cursor())
	END IF
	

END SUB

SUB FightSelect
	DIM e AS INTEGER
	DIM i AS INTEGER
	DIM p AS INTEGER

	SELECT CASE fight.curArea
		CASE 1
			SELECT CASE fight.curY
				CASE 150
					fight.def = 0
					fight.curArea = 2
					CALL LoadGFX(file.gfx + "cursor2.gfx", Cursor())
					FOR i = 1 TO 2
						IF player(i).dead = 0 AND player(i).ready = 1 THEN
							fight.curX = player(i).fightX
							fight.curY = player(i).fightY
							fight.curPlayer = i
							EXIT FOR
						ELSE
							fight.curPlayer = -1
						END IF
					NEXT i

				CASE 158  'Defend
					fight.def = 1
					fight.curArea = 2
					CALL LoadGFX(file.gfx + "cursor2.gfx", Cursor())
					FOR i = 1 TO 2
						IF player(i).dead = 0 AND player(i).ready = 1 THEN
							fight.curX = player(i).fightX
							fight.curY = player(i).fightY
							fight.curPlayer = i
							EXIT FOR
						ELSE
							fight.curPlayer = -1
						END IF
					NEXT i
					
				CASE 166  'Heal
					

			END SELECT

		CASE 2
			IF fight.def = 1 THEN
				IF player(1).fightY = fight.curY THEN
					player(1).deb = 1
					player(1).ready = 0
				ELSE
					player(2).deb = 1
					player(2).ready = 0
				END IF
				fight.def = 0
				fight.curArea = 1
				fight.curX = 140
				fight.curY = 150
				CALL LoadGFX(file.gfx + "cursor1.gfx", Cursor())

			ELSE
				fight.curArea = 3

				FOR i = 1 TO 4
					IF (enemy(i).exist > 0) THEN
						fight.curX = enemy(i).X
						fight.curY = enemy(i).Y
						fight.curEnemy = i
						EXIT FOR
					END IF
				NEXT i
			END IF
			
		CASE 3
			e = fight.curEnemy
			p = fight.curPlayer
			i = (player(p).at + INT(RND * player(p).rand)) - enemy(e).de - INT(RND * enemy(e).rand)

			fight.damage = i
			IF (i > 0) THEN
				enemy(e).hit = 1
				enemy(e).hp = enemy(e).hp - i
				IF enemy(e).hp < 1 THEN
					enemy(e).exist = 0
					player(1).exp = player(1).exp + enemy(e).exp
					fight.numEnemy = fight.numEnemy - 1
					IF fight.numEnemy = 0 THEN
						player(1).hp = player(1).hp + INT(RND * enemy(e).rand)
						player(2).hp = player(2).hp + INT(RND * enemy(e).rand)
						player(1).exp = player(1).exp + INT(RND * enemy(e).rand)
						CLS
						PRINT "You Win"
						IF player(1).exp > player(1).next THEN
							PRINT "You earned a new stash. Head to you the local school to store your pot."
						END IF
						SLEEP
						fight.battle = 0
					END IF
				END IF
				rate.hTS = TIMER
			ELSE
				enemy(e).hit = 2
				rate.hTS = TIMER
			END IF
			player(p).ready = 0
			fight.curArea = 4
	END SELECT
	
	FOR i = 1 TO 2
		IF (player(i).dead = 0) AND (player(i).ready = 1) THEN
			fight.curPlayer = i
			EXIT FOR
		ELSE
			fight.curPlayer = -1
		END IF
	NEXT i

	IF fight.curPlayer = -1 THEN
		CALL LoadGFX(file.gfx + "cursor2.gfx", Cursor())
		fight.turn = 0
		rate.cAS = TIMER
	END IF

END SUB

SUB InitFight
	DIM i AS INTEGER
	DIM s AS STRING

	s = "girl" + STR$(INT(RND * player(1).level) + 1)
	CALL LoadGFX(file.sprite + s + ".gfx", enemy1())
	CALL ReadGirlDat(file.sprite + s + ".dat", 1)

	s = "girl" + STR$(INT(RND * player(1).level) + 1)
	CALL LoadGFX(file.sprite + s + ".gfx", enemy2())
	CALL ReadGirlDat(file.sprite + s + ".dat", 2)

	s = "girl" + STR$(INT(RND * player(1).level) + 1)
	CALL LoadGFX(file.sprite + s + ".gfx", enemy3())
	CALL ReadGirlDat(file.sprite + s + ".dat", 3)

	s = "girl" + STR$(INT(RND * player(1).level) + 1)
	CALL LoadGFX(file.sprite + s + ".gfx", enemy4())
	CALL ReadGirlDat(file.sprite + s + ".dat", 4)
	       
	CALL LoadGFX(file.gfx + "ignog.gfx", player1())
	CALL LoadGFX(file.gfx + "err.gfx", player2())
	CALL LoadGFX(file.gfx + "cursor1.gfx", Cursor())

	fight.curArea = 1
	fight.curX = 140
	fight.curY = 150
	fight.numEnemy = 0
	FOR i = 1 TO 4
		IF enemy(i).exist > 0 THEN
			fight.numEnemy = fight.numEnemy + 1
		END IF
	NEXT i
	IF fight.numEnemy = 0 THEN fight.battle = 0

	fight.def = 0
	fight.turn = 1'INT(RND * 5)

	player(1).deb = 0
	player(2).deb = 0
	player(1).hit = 0
	player(2).hit = 0
	player(1).ready = 1
	player(2).ready = 1

END SUB

SUB InitStart
	enemy(1).X = 3 * 16
	enemy(1).Y = 6 * 16
	enemy(2).X = 5 * 16
	enemy(2).Y = 6 * 16
	enemy(3).X = 3 * 16
	enemy(3).Y = 8 * 16
	enemy(4).X = 5 * 16
	enemy(4).Y = 8 * 16
	
	fight.battle = 0
	fight.rand = 10

	file.deff = "Def GFX\"
	file.gfx = "GFX\"
	file.maps = "Maps\"
	file.sprite = "Sprites\"
	file.tiles = "Tiles\"

	CALL LoadGFX(file.maps + "def.map", map())
	CALL LoadGFX(file.maps + "def.obj", obj())
	CALL LoadGFX(file.gfx + "school1.gfx", city())
	CALL LoadGFX(file.gfx + "ignog.gfx", player1())
	CALL LoadGFX(file.gfx + "err.gfx", player2())
	CALL LoadGFX(file.gfx + "diag1.gfx", diag())

	CALL ReadMapDat(file.maps + "def.dat")

	mapInfo.gfx = 1

	player(1).rand = 1
	player(2).rand = 1
	player(1).at = 3 + INT(RND * player(1).rand) + 1
	player(2).at = 3 + INT(RND * player(2).rand) + 1
	player(1).de = 2 + INT(RND * player(1).rand) + 1
	player(2).de = 2 + INT(RND * player(2).rand) + 1
	player(1).dead = 0
	player(2).dead = 0
	player(1).exp = 0
	player(1).fightX = 15 * 16
	player(1).fightY = 6 * 16
	player(2).fightX = 15 * 16
	player(2).fightY = 8 * 16
	player(1).level = 1
	player(2).level = 1
	player(1).mapX = 10 * 16
	player(1).mapY = 5 * 16
	player(1).maxHP = 10 + INT(RND * player(1).rand) + 1
	player(2).maxHP = 10 + INT(RND * player(2).rand) + 1
	player(1).hp = player(1).maxHP
	player(2).hp = player(2).maxHP
	player(1).next = 10

	rate.hTD = .5
	rate.fRS = TIMER
	rate.fPS = 1 / 30

	scr(0) = 2560
	scr(1) = 200
END SUB

SUB LoadGFX (file AS STRING, gfx() AS INTEGER)

	DEF SEG = VARSEG(gfx(0))
	BLOAD file, 0
	DEF SEG
	
	
END SUB

SUB MoveCursor (dir AS STRING)
	DIM i AS INTEGER

	SELECT CASE fight.curArea
		CASE 1
			SELECT CASE dir
				CASE IS = "u"
					fight.curY = fight.curY - 8
					IF fight.curY < 150 THEN
						fight.curY = 150
					END IF
				CASE IS = "d"
					fight.curY = fight.curY + 8
					IF fight.curY > 166 THEN
						fight.curY = 166
					END IF
			END SELECT
		CASE 2
			CALL LoadGFX(file.gfx + "cursor2.gfx", Cursor())
			SELECT CASE dir
				CASE IS = "u"
					IF player(1).dead = 0 AND player(1).ready = 1 THEN
						fight.curX = player(1).fightX
						fight.curY = player(1).fightY
						fight.curPlayer = 1
					END IF

				CASE IS = "d"
					IF player(2).dead = 0 AND player(2).ready = 1 THEN
						fight.curX = player(2).fightX
						fight.curY = player(2).fightY
						fight.curPlayer = 2
					END IF

			END SELECT

		CASE 3
			CALL LoadGFX(file.gfx + "cursor2.gfx", Cursor())
			SELECT CASE dir
				CASE IS = "u"
					i = fight.curEnemy

					DO
						i = i + 1
						IF i > 4 THEN
							i = 0
						ELSE
							IF enemy(i).exist > 0 THEN
								fight.curX = enemy(i).X
								fight.curY = enemy(i).Y
								fight.curEnemy = i
								EXIT DO
							END IF
						END IF
					LOOP
					
				CASE IS = "d"
					i = fight.curEnemy
					DO
						i = i - 1
						IF i < 1 THEN
							i = 5
						ELSE
							IF enemy(i).exist > 0 THEN
								fight.curX = enemy(i).X
								fight.curY = enemy(i).Y
								fight.curEnemy = i
								EXIT DO
							END IF
						END IF
					LOOP
			END SELECT
	END SELECT
END SUB

SUB MovePlayer
	SELECT CASE INP(&H60)
		CASE IS = 75
			player(1).mapX = player(1).mapX - 16
			IF Collision THEN
				player(1).mapX = player(1).mapX + 16
			ELSE
				IF player(1).mapX < 0 THEN
					player(1).mapX = 0
				ELSE
					CALL CalcEvent
					fight.battle = INT(RND * fight.rand) + 1
				END IF
			END IF

		CASE IS = 77
			player(1).mapX = player(1).mapX + 16
			IF Collision THEN
				player(1).mapX = player(1).mapX - 16
			ELSE
				IF player(1).mapX > 304 THEN
					player(1).mapX = 304
				ELSE
					CALL CalcEvent
					fight.battle = INT(RND * fight.rand) + 1
				END IF
			END IF

		CASE IS = 72
			player(1).mapY = player(1).mapY - 16
			IF Collision THEN
				player(1).mapY = player(1).mapY + 16
			ELSE
				IF player(1).mapY < 0 THEN
					player(1).mapY = 0
				ELSE
					CALL CalcEvent
					fight.battle = INT(RND * fight.rand) + 1
				END IF
			END IF

		CASE IS = 80
			player(1).mapY = player(1).mapY + 16
			IF Collision THEN
				player(1).mapY = player(1).mapY - 16
			ELSE
				IF player(1).mapY > 176 THEN
					player(1).mapY = 176
				ELSE
					CALL CalcEvent
					fight.battle = INT(RND * fight.rand) + 1
				END IF
			END IF
	END SELECT
	
	IF fight.battle = 1 THEN
		CALL InitFight
	END IF

END SUB

SUB Prnt (a$, X AS INTEGER, Y AS INTEGER, col)
a$ = UCASE$(a$)
X = X - 5
COLOR col
FOR t = 1 TO LEN(a$)
X = X + 5

SELECT CASE MID$(a$, t, 1)
 CASE "A": PSET (X, Y + 5)
 DRAW "u4 e1 r1 f1 d4 u2 l2"
 CASE "B": PSET (X, Y)
 DRAW "d5 r2 e1 u1 h1 l1 r1 e1 h1 l1"
 CASE "C": PSET (X + 3, Y + 1)
 DRAW "h1 l1 g1 d3 f1 r1 e1"
 CASE "D": PSET (X, Y)
 DRAW "r1 d5 l1 r2 e1 u3 h1 l1"
 CASE "E": PSET (X + 3, Y)
 DRAW "l3 d2 r2 l2 d3 r3"
 CASE "F": PSET (X + 3, Y)
 DRAW "l3 d2 r2 l2 d3"
 CASE "G": PSET (X + 3, Y + 1)
 DRAW "h1 l1 g1 d3 f1 r1 e1 u1 l1"
 CASE "H": PSET (X, Y)
 DRAW "d5 u3 r3 u2 d5"
 CASE "I": PSET (X, Y)
 DRAW "r3 l2 d5 l1 r3"
 CASE "J": PSET (X + 1, Y)
 DRAW "r2 l1 d4 g1 h1 u1"
 CASE "K": PSET (X, Y)
 DRAW "d5 u3 r1 e2 g2 f2 d1"
 CASE "L": PSET (X, Y)
 DRAW "d5 r3"
 CASE "M": PSET (X, Y + 5)
 DRAW "u5 f1 r1 d1 l1 r2 u2 d5"
 CASE "N": PSET (X, Y + 5)
 DRAW "u5 f1 d1 f1 d1 f1 u5"
 CASE "O": PSET (X, Y + 1)
 DRAW "d3 f1 r1 e1 u3 h1 l1"
 CASE "P": PSET (X, Y + 5)
 DRAW "u5 r2 f1 g1 l1"
 CASE "Q": PSET (X, Y + 1)
 DRAW "d2 r1 g1 f1 r1 u1 r1 u3 h1 l1"
 CASE "R": PSET (X, Y + 5)
 DRAW "u2 e1 l1 u2 r2 f1 g1 f1 d2"
 CASE "S": PSET (X + 3, Y + 1)
 DRAW "h1 l1 g1 f1 r1 f1 d1 g1 l1 h1"
 CASE "T": PSET (X, Y)
 DRAW "r2 l1 d5"
 CASE "U": PSET (X, Y)
 DRAW "d5 r3 u5"
 CASE "V": PSET (X, Y)
 DRAW "d3 f1 d1 r1 u1 e1 u3"
 CASE "W": PSET (X, Y)
 DRAW "d5 e1 u1 r1 d1 f1 u5"
 CASE "X": PSET (X, Y)
 DRAW "d1 f1 d1 g1 d1 u1 e1 r1 f1 d1 u1 h1 u1 e1 u1"
 CASE "Y": PSET (X, Y)
 DRAW "d1 f1 d3 r1 u3 e1 u1"
 CASE "Z": PSET (X, Y)
 DRAW "r3 d1 g3 d1 r3"
 CASE "0": PSET (X, Y + 1)
 DRAW "d2 r1 g1 r1 d1 r1 e1 u2 l1 u1 r1 h1 l1"
 CASE "1": PSET (X, Y + 1)
 DRAW "e1 d5 l1 r3"
 CASE "2": PSET (X, Y)
 DRAW "r3 d2 l3 d3 r3 u1"
 CASE "3": PSET (X, Y)
 DRAW "r2 f1 g1 l2 r2 f1 d1 g1 l2"
 CASE "4": PSET (X + 3, Y + 3)
 DRAW "l3 u1 e2 d5"
 CASE "5": PSET (X + 3, Y)
 DRAW "l3 d2 r3 d3 l3"
 CASE "6": PSET (X + 3, Y)
 DRAW "l2 g1 d3 f1 r1 e1 u1 h1 l1"
 CASE "7": PSET (X, Y)
 DRAW "r3 d2 g3"
 CASE "8": PSET (X, Y + 1)
 DRAW "e1 r1 f1 g1 l1 g1 d1 f1 r1 e1 u1"
 CASE "9": PSET (X, Y + 5)
 DRAW "r3 u5 l3 d2 r2"
 CASE "%": PSET (X, Y)
 PSET (X, Y + 1)
 PSET (X, Y + 5)
 DRAW "e1 u1 e1 u1 e1"
 PSET (X + 3, Y + 5)
 PSET (X + 3, Y + 4)
 CASE ".": PSET (X + 1, Y + 5)
 CASE "?": PSET (X, Y)
 PSET (X + 3, Y + 5)
 PSET (X + 3, Y + 3)
 DRAW "e1 u1 h1 l1 g1 d1"
 CASE ",": PSET (X + 1, Y + 5)
 PSET (X, Y + 6)
 PSET (X + 1, Y + 4)
 CASE "!": PSET (X + 2, Y)
 DRAW "d3"
 PSET (X + 2, Y + 5)
 CASE "-": LINE (X + 1, Y + 2)-(X + 3, Y + 2)
 CASE "/": LINE (X + 1, Y + 5)-(X + 3, Y)
END SELECT
NEXT t

END SUB

SUB PutGFX (X AS INTEGER, Y AS INTEGER, gfx() AS INTEGER)
	DIM col AS INTEGER
	DIM i AS INTEGER
	DIM j AS INTEGER
	DIM with AS INTEGER

	with = gfx(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO gfx(1) - 1
			DEF SEG = VARSEG(gfx(0))
			col = PEEK(VARPTR(gfx(2)) + i + with * j)
			DEF SEG
		       
			IF NOT (col = 0) THEN
				IF ((X + i) < 320) AND ((Y + j) < 200) THEN
					DEF SEG = VARSEG(scr(0))
					POKE VARPTR(scr(2)) + X + i + 320& * (Y + j), col
					DEF SEG
				END IF
			END IF
		NEXT j
	NEXT i
END SUB

SUB ReadGirlDat (file AS STRING, i AS INTEGER)
	OPEN file FOR INPUT AS #1

	enemy(i).exist = INT(RND * 2)
	INPUT #1, enemy(i).at
	INPUT #1, enemy(i).de
	INPUT #1, enemy(i).exp
	enemy(i).hit = 0
	INPUT #1, enemy(i).hp
	INPUT #1, enemy(i).name
	enemy(i).name = enemy(i).name + STR$(i)
	enemy(i).max = enemy(i).hp
	INPUT #1, enemy(i).rand

	CLOSE #1

END SUB

SUB ReadMapDat (file AS STRING)
	OPEN file FOR INPUT AS #1

	INPUT #1, mapInfo.con1
	INPUT #1, mapInfo.con2
	INPUT #1, mapInfo.con3
	INPUT #1, mapInfo.con4
	INPUT #1, mapInfo.x1
	INPUT #1, mapInfo.y1
	INPUT #1, mapInfo.x2
	INPUT #1, mapInfo.y2
	INPUT #1, mapInfo.x3
	INPUT #1, mapInfo.y3
	INPUT #1, mapInfo.x4
	INPUT #1, mapInfo.y4

	CLOSE #1
END SUB

SUB SelectFight
	SELECT CASE in
		CASE IS = CHR$(0) + CHR$(75)
			CALL MoveCursor("l")
		CASE IS = CHR$(0) + CHR$(77)
			CALL MoveCursor("r")
		CASE IS = CHR$(0) + CHR$(72)
			CALL MoveCursor("u")
		CASE IS = CHR$(0) + CHR$(80)
			CALL MoveCursor("d")
		CASE IS = CHR$(13)
			CALL FightSelect
		CASE IS = CHR$(9)
			fight.battle = 0
	END SELECT
END SUB

SUB SetPalette1
	DIM index AS INTEGER
	DIM a AS INTEGER

	'pal() = red + (256 * green) + (65536 * blue)

	index = 0
	colour.custom = index
	pal(index) = 0
	index = index + 1
	pal(index) = 63 + (256 * 63) + (65536 * 63)
	index = index + 1
	index = 14
	pal(index) = 63 + (256 * 63) + (65536 * 63)
	index = 15
	
	'GREYS - .5 red, .5 green, .5 blue
	colour.grey = index
	FOR a = 60 TO 4 STEP -4
		pal(index) = a + (256 * a) + (65536 * a)
		index = index + 1
	NEXT a

	'REDS - 1 red
	colour.red = index
	FOR a = 52 TO 4 STEP -8
	   pal(index) = 63 + (256 * a) + (65536 * a)
	   index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
	   pal(index) = a + (256 * 0) + (65536 * 0)
		index = index + 1
	NEXT a

	'ORANGES - 1 red, .5 green
	colour.orange = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * (a \ 2 + 31)) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * (a \ 2)) + (65536 * 0)
		index = index + 1
	NEXT a

	'BROWNS - .6 red, .3 green
	colour.brown = index
	pal(index) = 63 + (256 * 56) + (65536 * 49)
	index = index + 1
	pal(index) = 60 + (256 * 51) + (65536 * 42)
	index = index + 1
	pal(index) = 57 + (256 * 46) + (65536 * 35)
	index = index + 1
	pal(index) = 54 + (256 * 41) + (65536 * 28)
	index = index + 1
	pal(index) = 51 + (256 * 36) + (65536 * 21)
	index = index + 1
	pal(index) = 48 + (256 * 31) + (65536 * 14)
	index = index + 1
	pal(index) = 45 + (256 * 26) + (65536 * 7)
	index = index + 1
	pal(index) = 42 + (256 * 21) + (65536 * 0)
	index = index + 1
	pal(index) = 36 + (256 * 17) + (65536 * 0)
	index = index + 1
	pal(index) = 30 + (256 * 15) + (65536 * 0)
	index = index + 1
	pal(index) = 25 + (256 * 12) + (65536 * 0)
	index = index + 1
	pal(index) = 19 + (256 * 10) + (65536 * 0)
	index = index + 1
	pal(index) = 14 + (256 * 7) + (65536 * 0)
	index = index + 1
	pal(index) = 8 + (256 * 5) + (65536 * 0)
	index = index + 1
	pal(index) = 3 + (256 * 2) + (65536 * 0)
	index = index + 1


	'YELLOWS - 1 red, 1 green
	colour.yellow = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * 63) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * a) + (65536 * 0)
		index = index + 1
	NEXT a

	'CHARTRUESE - .5 red, 1 green
	colour.chartruese = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = ((a \ 2) + 31) + (256 * 63) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = (a \ 2) + (256 * a) + (65536 * 0)
		index = index + 1
	NEXT a

	'GREENS - 1 green
	colour.green = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * 63) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * a) + (65536 * 0)
		index = index + 1
	NEXT a

	'SPRING GREEN - 1 green, .5 blue
	colour.springGreen = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * 63) + (65536 * ((a \ 2) + 31))
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * a) + (65536 * (a \ 2))
		index = index + 1
	NEXT a

	'CYANS - 1 green, 1 blue
	colour.cyan = index
	FOR a = 52 TO 4 STEP -8
	       pal(index) = a + (256 * 63) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * a) + (65536 * a)
		index = index + 1
	NEXT a

	'AZURE - .5 green, 1 blue
	colour.azure = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * ((a \ 2) + 31)) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * (a \ 2)) + (65536 * a)
		index = index + 1
	NEXT a

	'BLUES - 1 blue
	colour.blue = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * a) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * 0) + (65536 * a)
		index = index + 1
	NEXT a

	'PURPLES - .5 red, 1 blue
	colour.purple = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = (a \ 2 + 31) + (256 * a) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = (a \ 2) + (0) + (65536 * a)
		index = index + 1
	NEXT a

	'MAGENTAS - 1 red, 1 blue
	colour.magenta = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * a) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * 0) + (65536 * a)
		index = index + 1
	NEXT a

	'FUCHSIA -> 1 red, .5 blue
	colour.fuchsia = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * a) + (65536 * ((a \ 2) + 31))
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * 0) + (65536 * (a \ 2))
		index = index + 1
	NEXT a

	colour.gradient = index
	index = index + 15
	colour.blink = index
	index = index + 15
	colour.reserved = index

	'MOUSE COLOR
	index = 255
	pal(index) = 63 + (256 * 63) + (65536 * 63)

	PALETTE USING pal
END SUB

SUB ShowGFX
	PUT (0, 0), scr, PSET
END SUB

SUB ShowText
	DIM i AS INTEGER

	' prnt "Text to be displayed", x, y, color
	IF fight.battle = 1 THEN
		Prnt "Attack", 145, 155, 1
		Prnt "Defend", 145, 163, 1
		Prnt "Heal", 145, 171, 1

		Prnt "   HP/ Max", 212, 153, 1
		Prnt "Ig" + STR$(player(1).hp) + STR$(player(1).maxHP), 212, 163, 1
		Prnt "Er" + STR$(player(2).hp) + STR$(player(2).maxHP), 212, 171, 1

		IF fight.curArea = 3 OR fight.curArea = 4 THEN
			Prnt enemy(fight.curEnemy).name, 58, 155, 1
			Prnt "A" + STR$(enemy(fight.curEnemy).at) + " D" + STR$(enemy(fight.curEnemy).de), 53, 163, 1
			Prnt STR$(enemy(fight.curEnemy).hp) + " /" + STR$(enemy(fight.curEnemy).max), 53, 171, 1

			FOR i = 1 TO 4
				IF enemy(i).hit = 1 THEN
					Prnt STR$(fight.damage), enemy(i).X, enemy(i).Y, 1
					IF TIMER - rate.hTS > rate.hTD THEN
						enemy(i).hit = 0
						fight.curArea = 1
						fight.curX = 140
						fight.curY = 150
						CALL LoadGFX(file.gfx + "cursor1.gfx", Cursor())
					END IF
				ELSEIF enemy(i).hit = 2 THEN
					Prnt "Miss!", enemy(i).X, enemy(i).Y, 1
					IF TIMER - rate.hTS > rate.hTD THEN
						enemy(i).hit = 0
						fight.curArea = 1
						fight.curX = 140
						fight.curY = 150
						CALL LoadGFX(file.gfx + "cursor1.gfx", Cursor())

					END IF
				END IF
			NEXT i
			
		END IF
		IF fight.curArea = 5 THEN
			FOR i = 1 TO 2
				IF player(i).hit = 1 THEN
					Prnt STR$(fight.damage), player(i).fightX, player(i).fightY, 1
					IF TIMER - rate.hTS > 1 THEN
						player(i).hit = 0
					END IF
				ELSEIF player(i).hit = 2 THEN
					Prnt "Miss!", player(i).fightX, player(i).fightY, 1
					IF TIMER - rate.hTS > 1 THEN
						player(i).hit = 0
					END IF
				END IF
			NEXT i
		END IF
	END IF
END SUB

SUB UpdatePaletteGradient
	STATIC switch AS INTEGER
	STATIC index AS INTEGER

	index = index + switch
	IF (index > 12) THEN
		switch = -1
	ELSEIF (index < 3) THEN
		switch = 1
	END IF

	PALETTE 2, pal(ABS(switch) + switch + 1)
	PALETTE 225, pal(colour.grey + index)
	PALETTE 226, pal(colour.red + index)
	PALETTE 227, pal(colour.orange + index)
	PALETTE 228, pal(colour.brown + index)
	PALETTE 229, pal(colour.chartruese + index)
	PALETTE 230, pal(colour.green + index)
	PALETTE 231, pal(colour.springGreen + index)
	PALETTE 232, pal(colour.cyan + index)
	PALETTE 233, pal(colour.azure + index)
	PALETTE 234, pal(colour.blue + index)
	PALETTE 235, pal(colour.purple + index)
	PALETTE 236, pal(colour.magenta + index)
	PALETTE 237, pal(colour.fuchsia + index)

	PALETTE 238, pal(index * 15 + 2)
	PALETTE 239, pal(index * 15 + 12)

	IF (switch = -1) THEN
		PALETTE 240, pal(colour.grey + 7)
		PALETTE 241, pal(colour.red + 7)
		PALETTE 242, pal(colour.orange + 7)
		PALETTE 243, pal(colour.brown + 7)
		PALETTE 244, pal(colour.chartruese + 7)
		PALETTE 245, pal(colour.green + 7)
		PALETTE 246, pal(colour.springGreen + 7)
		PALETTE 247, pal(colour.cyan + 7)
		PALETTE 248, pal(colour.azure + 7)
		PALETTE 249, pal(colour.blue + 7)
		PALETTE 250, pal(colour.purple + 7)
		PALETTE 251, pal(colour.magenta + 7)
		PALETTE 252, pal(colour.fuchsia + 7)
		PALETTE 253, pal(index * 15 + 2)
		PALETTE 254, pal(index * 15 + 12)
	ELSE
		PALETTE 240, pal(0)
		PALETTE 241, pal(0)
		PALETTE 242, pal(0)
		PALETTE 243, pal(0)
		PALETTE 244, pal(0)
		PALETTE 245, pal(0)
		PALETTE 246, pal(0)
		PALETTE 247, pal(0)
		PALETTE 248, pal(0)
		PALETTE 249, pal(0)
		PALETTE 250, pal(0)
		PALETTE 251, pal(0)
		PALETTE 252, pal(0)
		PALETTE 253, pal(0)
		PALETTE 254, pal(0)
	END IF
	SELECT CASE pCol
		CASE 254
			IF switch = -1 THEN
				PALETTE 255, pal(index * 15 + 12)
			ELSE
				PALETTE 255, pal(1)
			END IF
		CASE 253
			IF switch = -1 THEN
				PALETTE 255, pal(index * 15 + 2)
			ELSE
				PALETTE 255, pal(1)
			END IF
		CASE IS >= 240
			IF switch = -1 THEN
				PALETTE 255, pal((((pCol MOD 15) + 1) * 15) + 7)
			ELSE
				PALETTE 255, pal(1)
			END IF
		CASE 239
			PALETTE 255, pal(index * 15 + 2)
	       
		CASE 238
			PALETTE 255, pal(index * 15 + 12)
		CASE IS >= 225
			PALETTE 255, pal((((pCol MOD 15) + 1) * 15) + index)
		CASE 2
			IF switch = -1 THEN
				PALETTE 255, pal(1)
			ELSE
				PALETTE 255, pal(29)
			END IF
		CASE ELSE
			PALETTE 255, pal(pCol)
	END SELECT
END SUB

SUB WelcomeScreen
PRINT "The local school girls took all of Ignignogks and Err's pot."
PRINT "Walk around and bash the shit out of those girls for your dope."
PRINT
SLEEP
END SUB

