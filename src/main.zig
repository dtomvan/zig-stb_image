const std = @import("std");
const process = std.process;

const c = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", {});
    @cDefine("STBI_NO_SIMD", {});
    @cDefine("STBI_FAILURE_USERMSG", {});
    @cDefine("STBI_NO_TGA", {}); // stbi__tga_test uses goto
    @cDefine("STBI_NO_HDR", {});
    @cInclude("stb_image.h");
});

pub fn main() anyerror!void {
    var arg_it = process.args();
    _ = arg_it.skip();

    const image_path = (arg_it.next() orelse {
        std.debug.print("Usage: zig-stb_image file\n", .{});
        return error.InvalidArgs;
    });
    var width: c_int = 0;
    var height: c_int = 0;
    var channels_in_file: c_int = undefined;
    const image_data: [*c]u8 = c.stbi_load(image_path, &width, &height, &channels_in_file, 0);
    defer c.stbi_image_free(image_data);

    if (image_data) |image_bytes| {
        const image_slice: []u8 = image_bytes[0..@intCast(width * height * channels_in_file)];
        std.debug.print("successfully loaded \"{s}\": width: {d} height: {d} channels: {d} bytes: {d}\n", .{ image_path, width, height, channels_in_file, image_slice.len });
    } else {
        std.debug.print("failed to load \"{s}\": {s}\n", .{ image_path, c.stbi_failure_reason() });
    }
}
