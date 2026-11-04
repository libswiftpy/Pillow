import PIL
import Python
import Testing

@Suite @MainActor
struct PILTests {
    @Test func savesAndLoadsEveryBuiltInFormat() throws {
        PyRuntime.additionalModules = [.pil]
        try PyRuntime.initialize()
        let code = try PythonCompiler.compile("""
        import io
        from PIL import Image, ImageDraw, ImageFont
        image = Image.new('RGB', (8, 8), 'red')
        ImageDraw.Draw(image).text((0, 0), 'P', font=ImageFont.load_default())
        sizes = []
        for format in ['PNG', 'JPEG', 'WEBP']:
            data = io.BytesIO()
            image.save(data, format)
            sizes.append(Image.open(io.BytesIO(data.getvalue())).size)
        """)
        try PyRuntime.execute(code)
        #expect(try PyRuntime.evaluate("sizes") == "[(8, 8), (8, 8), (8, 8)]")
    }
}
