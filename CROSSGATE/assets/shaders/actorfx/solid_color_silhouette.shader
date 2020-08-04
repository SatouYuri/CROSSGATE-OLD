shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : hint_color;
uniform float mixture;

void fragment() 
{
    COLOR = texture(TEXTURE, UV);
    COLOR.rgb = mix(COLOR.rgb, color.rgb, mixture);
}