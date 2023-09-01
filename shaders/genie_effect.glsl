vec2 remap(vec2 uv, vec2 inputLow, vec2 inputHigh, vec2 outputLow, vec2 outputHigh){
    vec2 t = (uv - inputLow)/(inputHigh - inputLow);
    vec2 final = mix(outputLow,outputHigh,t);
    return final;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    float f = abs(cos(iTime*2.0));
    
    float t = uv.y;
    float bias = sin(t*3.14)*0.1;
    bias = pow(bias,0.9);
    
    float BOTTOM_POS = 0.25;
    float BOTTOM_THICKNESS = 0.1;
    float MINI_FRAME_THICKNESS = 0.1;
    vec2 MINI_FRAME_POS = vec2(0.1,0.1);
    
    float min_x_curve = mix((BOTTOM_POS-BOTTOM_THICKNESS/2.0)+bias,0.0,t);
    float max_x_curve = mix((BOTTOM_POS+BOTTOM_THICKNESS/2.0)-bias,1.0,t);
    float min_x = mix(min_x_curve,MINI_FRAME_POS.x,f);
    float max_x = mix(max_x_curve,MINI_FRAME_POS.x+MINI_FRAME_THICKNESS,f);
    float min_y = mix(0.0,MINI_FRAME_POS.y,f);
    float max_y = mix(1.0,MINI_FRAME_POS.y+MINI_FRAME_THICKNESS,f);
    //float min_y = 0.0;
    //float max_y = f;
    vec2 modUV = remap(uv, vec2(min_x,min_y), vec2(max_x,max_y), vec2(0.0), vec2(1.0));
    vec2 finalUV = mix(uv,modUV,1.0*f);
    
    vec3 tex = texture(iChannel0, finalUV).rgb;
    tex = finalUV.x>1.0||finalUV.x<0.0?vec3(0.0):tex;
    tex = finalUV.y>1.0||finalUV.y<0.0?vec3(0.0):tex;
    // Time varying pixel color
    vec3 col = tex;
    
    // Output to screen
    fragColor = vec4(col,1.0);
}

void main() {
    
}