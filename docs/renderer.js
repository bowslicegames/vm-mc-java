// docs/renderer.js
export class GLCmdRenderer {
  constructor(canvas) {
    this.canvas = canvas;
    this.device = null;
    this.context = null;
    this.pipeline = null;
    this.textures = new Map();
    this.currentTexture = null;
  }

  async init() {
    if (!navigator.gpu) throw new Error("WebGPU not supported");
    const adapter = await navigator.gpu.requestAdapter();
    this.device = await adapter.requestDevice();
    this.context = this.canvas.getContext('webgpu');
    const format = navigator.gpu.getPreferredCanvasFormat();
    this.context.configure({ device: this.device, format });
    await this._createPipeline(format);
  }

  async _createPipeline(format) {
    const vs = `
      @vertex fn vs_main(@builtin(vertex_index) vi : u32) -> @builtin(position) vec4<f32> {
        var pos = array<vec2<f32>, 3>(
          vec2<f32>(-0.5, -0.5),
          vec2<f32>(0.5, -0.5),
          vec2<f32>(0.0, 0.5)
        );
        return vec4<f32>(pos[vi], 0.0, 1.0);
      }`;
    const fs = `
      @fragment fn fs_main() -> @location(0) vec4<f32> {
        return vec4<f32>(0.2, 0.6, 0.9, 1.0);
      }`;
    const vsModule = this.device.createShaderModule({ code: vs });
    const fsModule = this.device.createShaderModule({ code: fs });

    this.pipeline = this.device.createRenderPipeline({
      layout: "auto",
      vertex: {
        module: vsModule,
        entryPoint: "vs_main",
      },
      fragment: {
        module: fsModule,
        entryPoint: "fs_main",
        targets: [{ format }],
      },
      primitive: { topology: "triangle-list" },
    });
  }

  async exec(cmd) {
    // cmd: { name: 'CMD_CLEAR', args: [r,g,b,a] } or similar
    switch (cmd.name) {
      case 'CMD_CLEAR':
        this._clear(cmd.args);
        break;
      case 'CMD_DRAW_TRI':
        this._drawTri();
        break;
      default:
        console.warn("Unknown cmd", cmd);
    }
  }

  _clear([r,g,b,a]) {
    const encoder = this.device.createCommandEncoder();
    const view = this.context.getCurrentTexture().createView();
    const pass = encoder.beginRenderPass({
      colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: 'clear', storeOp: 'store' }]
    });
    pass.end();
    this.device.queue.submit([encoder.finish()]);
  }

  _drawTri() {
    const encoder = this.device.createCommandEncoder();
    const view = this.context.getCurrentTexture().createView();
    const pass = encoder.beginRenderPass({
      colorAttachments: [{ view, loadOp: 'load', storeOp: 'store' }]
    });
    pass.setPipeline(this.pipeline);
    pass.draw(3, 1, 0, 0);
    pass.end();
    this.device.queue.submit([encoder.finish()]);
  }
}

// Example helper to run a JSON command stream
export async function renderFromCommands(canvas, commands) {
  const r = new GLCmdRenderer(canvas);
  await r.init();
  for (const c of commands) {
    await r.exec(c);
  }
}
