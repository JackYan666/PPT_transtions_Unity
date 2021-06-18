Shader "Jack Shaders/21悬挂 Drape"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        u_ratio ("Ratio", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets\Shaders\Tools\Tools.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            
            sampler2D _MainTex;
            sampler2D _SecondTex;
            fixed u_ratio;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            
            #define PI 3.1415926
            // tent 函数，用于不同关键帧的线性插值
            float triFun(float x, float l, float c, float r)
            {
                if (l == c) l = c - 0.0001;
                if(r == c) r = c + 0.0001;
                float y1 = (x - l) / (c - l);
                float y2 = (x - r) / (c - r);
                return min(clamp(y1, 0.0, 1.0), clamp(y2, 0.0, 1.0));
            }
            float random(fixed2 st)
            {
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            
            fixed3 transform(fixed2 texCoord)
            {
                fixed2 res = texCoord;
                float t1 = 0.5;
                float t2 = 0.6;
                float t3 = 0.7;
                float t4 = 1.0;
                
                // 变换的思想类似于：动画的关键帧，在关键时间点定义好变换形式，然后插值
                // 对 x 坐标的关键帧变换表达式
                float fx1_left = 0.0;
                float fx2_left = 0.1 * res.y * (1.0 - res.y);
                float fx3_left = 0.1 * pow(1.0 - res.y, 2.0);
                float fx4_left = 0.0;
                float fx1_right = 1.0;
                float fx2_right = 1.0 - 0.05 * res.y * (1.0 - res.y);
                float fx3_right = 1.0 - 0.05 * pow(1.0 - res.y, 2.0);
                float fx4_right = 1.0;
                // 对x的关键帧进行插值，使用 tent 函数
                float deltaX_left = triFun(u_ratio, t1, t1, t2) * (fx1_left)
                + triFun(u_ratio, t1, t2, t3) * (fx2_left)
                + triFun(u_ratio, t2, t3, t4) * (fx3_left)
                + triFun(u_ratio, t3, t4, t4) * (fx4_left);
                float deltaX_right = triFun(u_ratio, t1, t1, t2) * (fx1_right)
                + triFun(u_ratio, t1, t2, t3) * (fx2_right)
                + triFun(u_ratio, t2, t3, t4) * (fx3_right)
                + triFun(u_ratio, t3, t4, t4) * (fx4_right);
                // 对 x 坐标进行变换
                res.x = (res.x - deltaX_left) / (deltaX_right - deltaX_left);
                // 对 y 坐标的关键帧变换表达式
                float fy1_down = 0.0;
                float fy2_down = 0.3 * ((0.2 - 0.3) * res.x + 0.2);
                float fy3_down = 0.5 * ((0.2 - 0.3) * res.x + 0.2);
                float fy4_down = 0.0;
                float fy1_top = 1.0;
                float fy2_top = 1.0;
                float fy3_top = 1.0;
                float fy4_top = 1.0;
                // 对y的关键帧进行插值，使用 tent 函数
                float deltaY_down = triFun(u_ratio, t1, t1, t2) * (fy1_down)
                + triFun(u_ratio, t1, t2, t3) * (fy2_down)
                + triFun(u_ratio, t2, t3, t4) * (fy3_down)
                + triFun(u_ratio, t3, t4, t4) * (fy4_down);
                float deltaY_top = 1.0;
                // 对 y 坐标进行变换
                res.y = (res.y - deltaY_down) / (deltaY_top - deltaY_down);
                // 光影变化，和变换后的坐标一同返回
                float intensityOffset = 0.0;
                return fixed3(res, intensityOffset);
            }
            
            
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord=i.uv;
                fixed4 resColor = fixed4(u_ratio, 0.0, 0.0, 1.0);
                fixed4 texColor1 = tex2D(_MainTex, texCoord);
                fixed4 texColor2 = tex2D(_SecondTex, texCoord);
                
                if (u_ratio < 0.5)
                {
                    float R = pow(clamp(1.0 - u_ratio / 0.5, 0.0, 1.0), 2.0);
                    // 转到画布真实的像素坐标系进行变换
                    fixed2 coord = texCoord;
                    coord.y = 2.0 * R - coord.y;
                    
                    // 添加光影变化
                    float intensityOffset = -0.5 + 2.0 * (texCoord.y - R) ;
                    // 揭开的背面的部分
                    resColor = tex2D(_MainTex, coord) * (1.0 + intensityOffset);
                    //resColor = fixed4(1.0+intensityOffset,0.0,0.0,1.0);
                    if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0)
                        resColor = texColor1;
                    if(texCoord.y < R)
                        resColor = texColor2;
                }
                else
                {
                    fixed3 coord = transform(texCoord);
                    resColor = tex2D(_MainTex, coord.xy);
                    if(coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0)
                        resColor = texColor2;
                }
                return resColor ;
            }
            ENDCG
            
        }
    }
}
