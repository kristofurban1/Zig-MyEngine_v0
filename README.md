Roadmap:
- Rendering
  - [✔️] Shaders:  ShaderProgram compilation.
  - [✖️] VertexData: Setup for VBO and VAO, handling data management, transport, bounds, types. One time setup apart from data modification.
  - [✖️] RenderPipeline: Takes ShaderProgram, attaches uniforms, other render dependencies. One time setup
  - [✖️] RenderDraw: Takes RenderPipeline and VertexData, fills in frame specific data. Calls render draw. One time setup, Per frame call.
  - [✖️] TextureObject: Takes resource, stores texture and provides it for rendering. Handles loading and disposing of data.

- Graphics
  - [✖️] PrimitiveRenderer (rect)
  - [✖️] SpriteRenderer (rect+texture)
  - [✖️] TextRenderer (RawText)
  - [✖️] DebugGui (Imgui or custom implementation<text+rect+sprite>)

- General:
  - [✔️] ObjectChain: Stores comptime chain of objects with iterator interface.
  - [✔️] NamedTypeCodes: ObjectChain implementation for storing and searching pairings of Zig enums to C enum codes(u32) with string names for debugging.
  - [✔️] Reporter: Handles storage of logs and errors, provides immidiate and periodic interface for retrieving them.
  - [✖️] ResourceManager: Handles loading, unloading and storing external resources into memory.

- Engine 
  - [✖️] SceneManager: Handles bundles of resources, scripts, [...] during the lifetime of the application. 
