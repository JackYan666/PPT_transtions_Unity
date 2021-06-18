﻿Shader "Jack Shaders/20帘式 Curtain"
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
                float y1 = x / (c - l) - l / (c - l);
                float y2 = x / (c - r) + r / (r - c);
                return min(clamp(y1, 0.0, 1.0), clamp(y2, 0.0, 1.0));
            }
            float random(fixed2 st)
            {
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            fixed3 hash33(fixed3 p)
            {
                float n = sin(dot(p, fixed3(7, 157, 113)));
                return frac(fixed3(2097152, 262144, 32768) * n) * 2. - 1.;
            }
            float tetraNoise(in fixed3 p)
            {
                fixed3 i = floor(p + dot(p, (fixed3)(0.333333))); 
                 p -= i - dot(i, (fixed3)(0.166666));
                fixed3 i1 = step(p.yzx, p), i2 = max(i1, 1.0 - i1.zxy);
                 i1 = min(i1, 1.0 - i1.zxy);
                fixed3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
                fixed4 v = max(0.5 - fixed4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.0);
                fixed4 d = fixed4(dot(p, hash33(i)), dot(p1, hash33(i + i1)), dot(p2, hash33(i + i2)), dot(p3, hash33(i + 1.)));
                return clamp(dot(d, v * v * v * 8.) * 1.732 + .5, 0., 1.); // Not sure if clamping is necessary. Might be overkill.
            }
            // 一个 transform 完成单边窗帘纹理坐标的变换，所以在 main 里面要对 0.5 左右分别调用
            fixed3 transform(fixed2 texCoord)
            {
                fixed2 res = texCoord;
                // 变换的思想类似于：动画的关键帧，在关键时间点定义好变换形式，然后插值
                float t1 = 0.0;
                float t2 = 0.5 / 6.0;
                float t3 = 2.0 / 6.0;
                float t4 = 3.0 / 6.0;
                float t5 = 3.5 / 6.0;
                float t6 = 4.5 / 6.0;
                float t7 = 5.3 / 6.0;
                float t8 = 1.0;
                // 对 x 坐标的关键帧变换表达式
                float fx1 = 0.0;
                float fx2 = 0.5 * pow(res.y, 2.0);
                float fx3 = 0.5;
                float fx4 = 0.5 + 0.25 * pow(1.0 - res.y, 2.0);
                float fx5 = 0.5;
                float fx6 = 0.5 - 0.25 * pow(1.0 - res.y, 2.0);
                float fx7 = 1.0 - 0.75 * pow(1.0 - res.y, 2.0);
                float fx8 = 1.0;
                // 对x的关键帧进行插值，使用 tent 函数
                float deltaX = triFun(u_ratio, t1, t1, t2) * (fx1)
                + triFun(u_ratio, t1, t2, t3) * (fx2)
                + triFun(u_ratio, t2, t3, t4) * (fx3)
                + triFun(u_ratio, t3, t4, t5) * (fx4)
                + triFun(u_ratio, t4, t5, t6) * (fx5)
                + triFun(u_ratio, t5, t6, t7) * (fx6)
                + triFun(u_ratio, t6, t7, t8) * (fx7)
                + triFun(u_ratio, t7, t8, t8) * (fx8);
                // 对 x 坐标进行变换：大幅度的窗帘拉动 and 细微的偏移
                res.x = (res.x - deltaX) / (1.0 + 0.2 * u_ratio - deltaX);
                res.x = res.x - 0.02 * cos(20.0 * PI * res.x) * deltaX;
                // 对 y 坐标的关键帧变换表达式
                float fy1 = 0.0;
                float fy2 = 0.2 * pow(1.0 - res.x, 2.0);
                float fy3 = 0.0;
                float fy4 = 0.05 * pow(1.0 - (res.x), 2.0);
                float fy5 = 0.0;
                float fy6 = 0.05 * pow(1.0 - (res.x), 2.0);
                float fy7 = 0.3 * pow(1.0 - (res.x), 2.0);
                float fy8 = 0.0;
                // 对 y 的关键帧进行插值，使用 tent 函数
                float deltaY = triFun(u_ratio, t1, t1, t2) * (fy1)
                + triFun(u_ratio, t1, t2, t3) * (fy2)
                + triFun(u_ratio, t2, t3, t4) * (fy3)
                + triFun(u_ratio, t3, t4, t5) * (fy4)
                + triFun(u_ratio, t4, t5, t6) * (fy5)
                + triFun(u_ratio, t5, t6, t7) * (fy6)
                + triFun(u_ratio, t6, t7, t8) * (fy7)
                + triFun(u_ratio, t7, t8, t8) * (fy8);
                // 对 y 坐标进行变换：大幅度的窗帘拉动 and 细微的偏移
                res.y = (res.y - 1.0) / (1.0 - deltaY) + 1.0;
                res.y = res.y + 0.05 * sin(20.0 * PI * res.x) * deltaX * (1.0 - res.y) * random(fixed2(floor(res.x * 20.0), 1.0));
                float noise = tetraNoise(fixed3(res * fixed2(5.0, 0.2), u_ratio * 1.0));
                //res.x = res.x - clamp(0.2 * noise * pow(deltaX, 0.5),0.0,res.x);
                
                // 窗帘上形如三角函数的光影变化，和变换后的坐标一同返回
                float intensityOffset = 0.2 * cos(20.0 * PI * (res.x - clamp(0.2 * noise * pow(deltaX, 0.5), 0.0, res.x))) * deltaX;
                return fixed3(res, intensityOffset);
            }
            

            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord=i.uv;
                
                fixed4 resColor = fixed4(1.0, 0.0, 0.0, 1.0);
                fixed4 texColor2 = tex2D(_SecondTex, texCoord);
                // 对右半部分：从 0.5 -> 1.0 映射到 0.0 -> 1.0，经过 transform 后再映射回来
                if (texCoord.x > 0.5)
                {
                    fixed2 coord = fixed2(texCoord.x * 2.0 - 1.0, texCoord.y);
                    fixed3 res = transform(coord);
                    resColor = tex2D(_MainTex, fixed2(res.x * 0.5 + 0.5, res.y));
                    resColor = resColor * (1.0 + res.z);
                    // 对于上一张图超出 0-1 范围的地方，显示下一张图
                    if (res.x < 0.0 || res.x > 1.0 || res.y < 0.0 || res.y > 1.0)
                        resColor = texColor2;
                }
                // 对左半部分：从 0.0 -> 0.5 映射到 1.0 -> 0.0，经过 transform 后再映射回来
                if (texCoord.x <= 0.5)
                {
                    fixed2 coord = fixed2(1.0 - texCoord.x * 2.0, texCoord.y);
                    fixed3 res = transform(coord);
                    resColor = tex2D(_MainTex, fixed2(0.5 - res.x * 0.5, res.y));
                    
                    resColor = resColor * (1.0 + res.z);
                    if(res.x < 0.0 || res.x > 1.0 || res.y < 0.0 || res.y > 1.0)
                        resColor = texColor2;
                }
                return resColor;
            }
            ENDCG
            
        }
    }
}
