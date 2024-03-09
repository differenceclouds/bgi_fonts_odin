package main
import "core:fmt"
import "core:strings"
import rl   "vendor:raylib"

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




drawGlyph :: proc(glyph: Glyph, x: i32, y:i32, scale: i32, color: rl.Color) {
	for i :i32= 0; i < glyph.nVertices; i += 2 {
		x1 := glyph.vertices[i].X * scale + x
		y1 := glyph.vertices[i].Y * scale + y
		x2 := glyph.vertices[i + 1].X * scale + x
		y2 := glyph.vertices[i + 1].Y * scale + y
		if x1 == x2 && y1 == y2 do rl.DrawPixel(x1, y1, rl.GREEN)
		else do rl.DrawLine(x1, y1, x2, y2, color)
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

DrawMessage :: proc(message: string, font: Font, scale: i32, position: Vertex, color: rl.Color) -> Vertex {
	glyphX : i32 = 0
	glyphY : i32 = 0
	for i := 0; i < len(message); i += 1 {
		char : rune = cast(rune)message[i]
		glyphIndex : i32 = GetGlyphIndex(GetCodepoint(char))
		if glyphX == 0 && glyphIndex == 0 {
			continue
		}
		drawGlyph(font.glyphs[glyphIndex], glyphX + position.X, glyphY + position.Y, scale, color)
		glyphX += font.glyphs[glyphIndex].width * scale

		
		if i != len(message) - 2 {
			nextGlyph : Glyph = font.glyphs[glyphIndex + 1]
			if glyphX > 1024 - position.X - font.glyphs[glyphIndex + 1].width * scale {
				glyphX = 0
				glyphY += font.height * scale
			}
		} 

	}
	return Vertex{glyphX, glyphY}
}


User_Input :: struct {
    KeyLeftPressed:   bool,
    KeyRightPressed:  bool,
}

// process_user_input :: proc(user_input: ^User_Input) {
//     user_input^ = User_Input{
//         KeyLeftPressed = rl.IsKeyPressed(.INPUT_KEY_LEFT),
//         KeyLeftPressed = rl.IsKeyPressed(.INPUT_KEY_RIGHT),
//     }
// }




main :: proc() {

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
	demoFont := Fonts[0]
	// uiFont := FontList.litt
	// demoFont := FontList.trip

	rl.InitWindow(1024, 768, "single line fonts demo")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	// LoadCodepoints("k")
	// fmt.println(GetCodepoint('k')[1])
	// for i : i32 = 32; i < 100; i += 1 {
	// 	fmt.println(GetGlyphIndex(i))
	// }

	fmt.println(GetGlyphIndex(GetCodepoint('!')))
	

	for !rl.WindowShouldClose() {
		KeyLeftPressed := rl.IsKeyPressed(.LEFT)
		KeyRightPressed := rl.IsKeyPressed(.RIGHT)

		if KeyRightPressed {
			id := (demoFont.ID + 1) %% len(Fonts)
			demoFont = Fonts[id] 
		}
		if KeyLeftPressed {
			id := (demoFont.ID - 1) %% len(Fonts)
			demoFont = Fonts[id]
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		DrawMessage("Why shop at 5 or six stores when you could shop at just one!?", demoFont, 4, Vertex{16, 36}, rl.GREEN)

		uiMessage : string = strings.concatenate({"font: \"",demoFont.name,"\""})
		DrawMessage(uiMessage, uiFont, 3, Vertex{0,0}, rl.WHITE)

		rl.DrawLine(0, 36, 1024, 36, rl.WHITE)

		rl.EndDrawing()
	}
}






