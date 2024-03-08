package main
import rl   "vendor:raylib"

Vertex :: struct {
	X: i32,
	Y: i32
}

Glyph :: struct {
	width: i32,
	data_size: i32,
	nVertices: i32,
	vertices: [dynamic]Vertex
	// data: []i32
}

Font :: struct {
	nglyphs: i32,
	height: i32,
	desc_height: i32,
	glyphs: [dynamic]Glyph
}

importFontData :: proc(
		_nglyphs: i32,
		_height: i32,
		_desc_height: i32,
		_widths: []i32,
		_sizes: []i32,
		_glyphs_data: [][]i32
	) -> Font 
{
	font := Font{}

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




drawGlyph :: proc(glyph: Glyph, x: i32, y:i32, scale: i32) {
	for i :i32= 0; i < glyph.nVertices; i += 2 {
		x1 := glyph.vertices[i].X * scale + x
		y1 := glyph.vertices[i].Y * scale + y
		x2 := glyph.vertices[i + 1].X * scale + x
		y2 := glyph.vertices[i + 1].Y * scale + y
		rl.DrawLine(x1, y1, x2, y2, rl.GREEN)
	}
}


FontList :: enum {
	bold,
	euro,
	goth,
	lcom,
	litt,
	sans,
	scri,
	simp,
	trip,
	tscr,
}




main :: proc() {
	Fonts := #partial [FontList]Font {
		.bold = importFontData(bold_NGLYPHS, bold_height, bold_desc_height, bold_width, bold_size, bold_data),
		.euro = importFontData(euro_NGLYPHS, euro_height, euro_desc_height, euro_width, euro_size, euro_data),
		.goth = importFontData(goth_NGLYPHS, goth_height, goth_desc_height, goth_width, goth_size, goth_data),
		.lcom = importFontData(lcom_NGLYPHS, lcom_height, lcom_desc_height, lcom_width, lcom_size, lcom_data),
		.litt = importFontData(litt_NGLYPHS, litt_height, litt_desc_height, litt_width, litt_size, litt_data),
		.sans = importFontData(sans_NGLYPHS, sans_height, sans_desc_height, sans_width, sans_size, sans_data),
		.scri = importFontData(scri_NGLYPHS, scri_height, scri_desc_height, scri_width, scri_size, scri_data),
		.simp = importFontData(simp_NGLYPHS, simp_height, simp_desc_height, simp_width, simp_size, simp_data),
		.trip = importFontData(trip_NGLYPHS, trip_height, trip_desc_height, trip_width, trip_size, trip_data),
		.tscr = importFontData(tscr_NGLYPHS, tscr_height, tscr_desc_height, tscr_width, tscr_size, tscr_data),
	}


	font := Fonts[.trip]

	rl.InitWindow(1024, 768, "single line fonts demo")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		// rl.DrawLine(0, 0, 1024, 768, rl.WHITE)	
		glyphX:i32 = 0
		glyphY:i32 = 0
		scale:i32 = 8
		for i:i32 = 0; i < font.nglyphs; i += 1 {
			drawGlyph(font.glyphs[i], glyphX, glyphY, scale)
			glyphX += font.glyphs[i].width * scale
			if glyphX > 1024 {
				glyphX = 0
				glyphY += font.height * scale
			}
		}
		rl.EndDrawing()
	}
}






