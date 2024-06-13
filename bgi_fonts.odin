package bgi_fonts
import "core:fmt"
import "core:strings"
import "core:strconv"
import rl   "vendor:raylib"

Window :: struct { 
    name:	cstring,
    width:	i32, 
    height:	i32,
}

Vertex :: struct {
	X: i32,
	Y: i32
}

Glyph :: struct {
	value: int, // Character value (Unicode)
	width: i32,
	data_size: i32,
	nVertices: i32,
	vertices: [dynamic]Vertex
	// data: []i32
}

Font :: struct {
	name: string,
	ID: int,
	nglyphs: i32,
	height: i32,
	desc_height: i32,
	glyphs: [dynamic]Glyph
}


importFontData :: proc(
		_name: string,
		_id: int,
		_nglyphs: i32,
		_height: i32,
		_desc_height: i32,
		_widths: []i32,
		_sizes: []i32,
		_glyphs_data: [][]i32
	) -> Font 
{
	font := Font{}

	font.name = _name
	font.ID = _id
	font.nglyphs = _nglyphs
	font.height = _height
	font.desc_height = _desc_height
	font.glyphs = [dynamic]Glyph {}

	for i : i32 = 0; i < _nglyphs; i += 1 {
		append(&font.glyphs, importGlyphData(_widths[i], _sizes[i], _glyphs_data[i]))
	}
	return font
}

importGlyphData :: proc(_width: i32, _size: i32, _data : []i32) -> Glyph {
	glyph := Glyph {}

	glyph.data_size = _size
	glyph.width = _width
	//glyph.data = _data
	glyph.nVertices = _size / 2
	glyph.vertices = [dynamic]Vertex {}
	for i : i32 = 0; i < _size; i += 2 {
		append(&glyph.vertices, Vertex{_data[i], _data[i + 1]})
	}

	return glyph
}



DrawLineBresenham :: proc(x1: i32, y1: i32, x2: i32, y2: i32, color: rl.Color) {
	dx, dy, i, e : i32
	incx, incy, inc1, inc2 : i32
	x, y : i32

	dx = x2 - x1
	dy = y2 - y1

	if dx < 0 do dx = -dx
	if dy < 0 do dy = -dy

	incx = 1
	if x2 < x1 do incx = -1
	
	incy = 1
	if y2 < y1 do incy = -1

	x = x1
	y = y1

	if dx > dy {
		rl.DrawPixel(x, y, color)
		e = 2 * dy - dx
		inc1 = 2 * (dy - dx)
		inc2 = 2 * dy
		for i:i32 = 0; i < dx; i += 1 {
			if e >= 0 {
				y += incy
				e += inc1
			} else {
				e += inc2
			}
			x += incx
			rl.DrawPixel(x, y, color)
		}
	} else {
		rl.DrawPixel(x, y, color)
		e = 2 * dx - dy
		inc1 = 2 * (dx - dy)
		inc2 = 2 * dx
		for i:i32 = 0; i < dy; i += 1 {
			if e >= 0 {
				x += incx
				e += inc1
			} else {
				e += inc2
			}
			y += incy
			rl.DrawPixel(x, y, color)
		}
	}

}


drawGlyph :: proc(glyph: Glyph, x: i32, y:i32, scale: i32, color: rl.Color) {
	for i :i32= 0; i < glyph.nVertices; i += 2 {
		x1 := glyph.vertices[i].X * scale + x
		y1 := glyph.vertices[i].Y * scale + y
		x2 := glyph.vertices[i + 1].X * scale + x
		y2 := glyph.vertices[i + 1].Y * scale + y

		// rl.DrawPixel(x1, y1, rl.YELLOW)
		// rl.DrawPixel(x2, y2, rl.YELLOW)

		DrawLineBresenham(x1, y1, x2, y2, color)
		// if x1 == x2 && y1 == y2 do rl.DrawPixel(x1, y1, rl.YELLOW)
		// else {
			// rl.DrawLine(x1, y1, x2, y2, color)
		// }

	}
}

drawGlyphRL :: proc(glyph: Glyph, x: i32, y:i32, scale: i32, color: rl.Color) {
	for i :i32= 0; i < glyph.nVertices; i += 2 {
		x1 := glyph.vertices[i].X * scale + x
		y1 := glyph.vertices[i].Y * scale + y
		x2 := glyph.vertices[i + 1].X * scale + x
		y2 := glyph.vertices[i + 1].Y * scale + y

		rl.DrawLine(x1, y1, x2, y2, color)
		rl.DrawPixel(x1 - 1, y1, rl.YELLOW)
		rl.DrawPixel(x2 - 1, y2, rl.YELLOW)
	}
}



LoadCodepoints :: proc(_text: string) -> [^]rune {
	text := _text
	count : i32 = cast(i32)len(text)
	return rl.LoadCodepoints(&text, &count)
}

GetCodepoint :: proc(_glyph: rune) -> [^]rune {
	glyph := _glyph
	codepointByteCount :i32= 0;
	return rl.LoadCodepoints(&glyph, &codepointByteCount)
}

GetGlyphIndex :: proc(codepoint_ptr : [^]rune) -> i32 {
	codepoint : rune = codepoint_ptr[0]
	codepoints := GlyphLiterals
	index : i32 = 0;
	fallbackIndex : i32 = 27; // ?
	for i : i32 = 0; i < cast(i32)len(codepoints); i += 1 {
		if codepoints[i] == codepoint {
			index = i
			break
		}
	}
	if index == 0 && codepoints[0] != codepoint do index = fallbackIndex

	return index;
}

DrawMessage :: proc(window: Window, message: string, font: Font, scale: i32, position: Vertex, color: rl.Color) -> Vertex {
	glyphX : i32 = 0
	glyphY : i32 = 0

	words := strings.split_after(message, " ")

	for i := 0; i < len(words) ; i += 1 {
		for j := 0; j < len(words[i]); j += 1 {
			char : rune = cast(rune)words[i][j]
			glyphIndex : i32 = GetGlyphIndex(GetCodepoint(char))
			drawGlyph(font.glyphs[glyphIndex], glyphX + position.X, glyphY + position.Y, scale, color)
			glyphX += font.glyphs[glyphIndex].width * scale
		}
		if i < len(words) - 1 {
			nextwidth := MeasureText(words[i + 1], font, false).X * scale
			if glyphX > window.width - position.X - nextwidth {
				glyphX = 0
				glyphY += font.height * scale
			}
		}
	}
	return Vertex{glyphX, glyphY}
}

DrawAllGlyphs :: proc(window: Window, font: Font, scale: i32, position: Vertex, color: rl.Color) {
	glyphX : i32 = 0
	glyphY : i32 = 0
	for i : i32 = 0; i < font.nglyphs; i += 1 {
		drawGlyph(font.glyphs[i], glyphX + position.X, glyphY + position.Y, scale, color)
		glyphX += font.glyphs[i].width * scale
		if i < font.nglyphs - 1 {
			nextGlyph : Glyph = font.glyphs[i + 1]
			if glyphX > window.width - position.X - font.glyphs[i + 1].width * scale {
				glyphX = 0
				glyphY += font.height * scale
			}
		}
	} 
}

MeasureText :: proc(text: string, font: Font, includeSpaces: bool) -> Vertex {
	sizeX :i32= 0
	sizeY :i32= 0
	length := len(text)
	for i := 0; i < len(text); i += 1 {
		char : rune = cast(rune)text[i]
		glyphIndex : i32 = GetGlyphIndex(GetCodepoint(char))
		if !includeSpaces && glyphIndex == 0 do continue
		sizeX += font.glyphs[glyphIndex].width
	}
	if(sizeX > 0) do sizeY = font.height

	return {sizeX, sizeY}
}


User_Input :: struct {
    KeyLeftPressed:		bool,
    KeyRightPressed:	bool,
    KeyUpPressed:		bool,
    KeyDownPressed:		bool
}

// process_user_input :: proc(user_input: ^User_Input) {
//     user_input^ = User_Input{
//         KeyLeftPressed = rl.IsKeyPressed(.INPUT_KEY_LEFT),
//         KeyLeftPressed = rl.IsKeyPressed(.INPUT_KEY_RIGHT),
//     }
// }


int_to_string :: #force_inline proc(num: int) -> string {
	buf: [4]byte
	return strconv.itoa(buf[:], num)
}

main :: proc() {

	window := Window{"line-segment fonts demo", 1280, 720}
	rl.InitWindow(window.width, window.height, window.name)
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	Fonts := [dynamic]Font {}
	append(&Fonts, importFontData("bold", len(Fonts), bold_NGLYPHS, bold_height, bold_desc_height, bold_width, bold_size, bold_data))
	append(&Fonts, importFontData("euro", len(Fonts), euro_NGLYPHS, euro_height, euro_desc_height, euro_width, euro_size, euro_data))
	append(&Fonts, importFontData("goth", len(Fonts), goth_NGLYPHS, goth_height, goth_desc_height, goth_width, goth_size, goth_data))
	append(&Fonts, importFontData("lcom", len(Fonts), lcom_NGLYPHS, lcom_height, lcom_desc_height, lcom_width, lcom_size, lcom_data))
	append(&Fonts, importFontData("litt", len(Fonts), litt_NGLYPHS, litt_height, litt_desc_height, litt_width, litt_size, litt_data))
	append(&Fonts, importFontData("sans", len(Fonts), sans_NGLYPHS, sans_height, sans_desc_height, sans_width, sans_size, sans_data))
	append(&Fonts, importFontData("scri", len(Fonts), scri_NGLYPHS, scri_height, scri_desc_height, scri_width, scri_size, scri_data))
	append(&Fonts, importFontData("simp", len(Fonts), simp_NGLYPHS, simp_height, simp_desc_height, simp_width, simp_size, simp_data))
	append(&Fonts, importFontData("trip", len(Fonts), trip_NGLYPHS, trip_height, trip_desc_height, trip_width, trip_size, trip_data))
	append(&Fonts, importFontData("tscr", len(Fonts), tscr_NGLYPHS, tscr_height, tscr_desc_height, tscr_width, tscr_size, tscr_data))

	uiFont := Fonts[4]
	demoFont := Fonts[1]

	scale : i32 = 3
	// uiFont := FontList.litt
	// demoFont := FontList.trip
	// LoadCodepoints("k")
	// fmt.println(GetCodepoint('k')[1])
	// for i : i32 = 32; i < 100; i += 1 {
	// 	fmt.println(GetGlyphIndex(i))
	// }

	fmt.println(GetGlyphIndex(GetCodepoint('!')))
	

	for !rl.WindowShouldClose() {

		if rl.IsKeyPressed(.LEFT) {
			id := (demoFont.ID + 1) %% len(Fonts)
			demoFont = Fonts[id] 
		}
		if rl.IsKeyPressed(.RIGHT) {
			id := (demoFont.ID - 1) %% len(Fonts)
			demoFont = Fonts[id]
		}
		if rl.IsKeyPressed(.UP) {
			scale += 1
		}
		if rl.IsKeyPressed(.DOWN) {
			scale = max(1, scale - 1)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		messageposition := DrawMessage(window, "Why shop at 5 or six stores when you could shop at just one?!", demoFont, scale, Vertex{16, 36}, rl.WHITE)
		newY := messageposition.Y + 36 + demoFont.height * scale
		newY -= demoFont.desc_height * scale
		newY += 4
		rl.DrawLine(0, newY, window.width, newY, rl.GREEN)
		DrawAllGlyphs(window, demoFont, scale, Vertex{16, newY}, rl.WHITE)

		uiMessage : = strings.concatenate({"font: \"",demoFont.name,"\""})
		DrawMessage(window, uiMessage, uiFont, 3, Vertex{16,0}, rl.GREEN)
		uiMessage2 := strings.concatenate({ "  scale: ", int_to_string(cast(int)scale) })
		DrawMessage(window, uiMessage2, uiFont, 3, Vertex{window.width / 2, 0}, rl.GREEN)
		uiMessage3 := "interact with arrow keys"
		DrawMessage(window, uiMessage3, uiFont, 2, Vertex{window.width - 300, 10}, rl.GREEN)

		rl.DrawLine(0, 36, window.width, 36, rl.GREEN)

		rl.EndDrawing()
	}
}






