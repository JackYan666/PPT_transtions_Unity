Shader "Jack Shaders/18闪耀 Glitter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        _Ratio ("Ratio", Range(0, 1)) = 0
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
            fixed _Ratio;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            
            
            #define PI 3.1415926
            #define u_width  2000
            #define u_height  1125
            // 此变换函数对 蜂窝状 进行缩放和旋转
            fixed2 transform(fixed2 texcoord, float theta, fixed2 hexagonNum)
            {
                fixed2 res = texcoord;
                res = res * fixed2(u_width, u_height);
                res = res * hexagonNum;
                res = fixed2(dot(fixed2(cos(theta), sin(theta)), res), dot(fixed2(-sin(theta), cos(theta)), res));
                res = res / fixed2(u_width, u_height);
                return res;
            }
            float and(float a, float b)
            {
                if (a > 0.5 && b > 0.5)      return 1.0;
                    else                        return 0.0;
            }
            float or(float a, float b)
            {
                if(a > 0.5 || b > 0.5)     return 1.0;
                    else                        return 0.0;
            }
            float not(float a)
            {
                return 1.0 - a;
            }
            float random(fixed2 st)
            {
                st = floor(st * 1000.0) / 1000.0 + fixed2(0.001, 0.001); // 保留三位小数，防止由于精度不够，出现误差
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            fixed2 transform(fixed2 texCoord, float theta, fixed2 axisPos, fixed2 hexagonNum)
            {
                fixed2 res = texCoord - axisPos;
                // 蜂窝边缘的宽度
                float lineWidth = 2.0;
                // 执行旋转和投影
                res.x = res.x / cos(theta);
                res.y = res.y / (1.0 - res.x * sin(theta));
                res.x = res.x / (1.0 - res.x * sin(theta));
                // r5 代表一个最小拼接块里中间的六边形
                float k1 = 1.0 / (0.52 - lineWidth); // 此处的 0.52 本应是 0.5 但是有bug
                fixed2 coord1 = transform(res, PI / 3.0, hexagonNum);
                fixed2 coord2 = transform(res, -PI / 3.0, hexagonNum);
                fixed2 coord3 = transform(res, 0.0, hexagonNum);
                float v1 = floor(clamp(abs(coord1.y) * k1, 0.0, 1.0));
                float v2 = floor(clamp(abs(coord2.y) * k1, 0.0, 1.0));
                float v3 = floor(clamp(abs(coord3.y) * k1, 0.0, 1.0));
                float r5 = not(or(or(v1, v2), v3)) ;
                // 六边形之外的区域，坐标设置为-1，取背景色
                if (r5 < 1.0)
                    res = fixed2(-1.001, -1.001);
                res = res + axisPos;    // 从 (0,0) 移动到 axisPos
                return res;
            }
            
            
            fixed2 generateHoneyComb(fixed2 hexagonNum, fixed2 texCoord, float lineWidth)
            {
                // 确定每个 最小拼接块 的中心
                fixed2 center = floor(texCoord * hexagonNum) * (1.0 / hexagonNum) + 0.5 / hexagonNum;
                fixed2 coord = texCoord - center;
                // 为了画出一个六边形，分别执行 0度、60度、120度 旋转
                fixed2 coord1 = transform(coord, PI / 3.0, hexagonNum);
                fixed2 coord2 = transform(coord, -PI / 3.0, hexagonNum);
                fixed2 coord3 = transform(coord, 0.0, hexagonNum);
                // 分别求出最小拼接块内的各个组块的表达式，通过布尔运算进行组合
                float v1 = floor(clamp(abs(coord1.y) / (0.5 - lineWidth), 0.0, 1.0));
                float v2 = floor(clamp(abs(coord2.y) / (0.5 - lineWidth), 0.0, 1.0));
                float v3 = floor(clamp(abs(coord3.y) / (0.5 - lineWidth), 0.0, 1.0));
                float v4 = floor(clamp(abs(coord1.y) / (0.5 + lineWidth), 0.0, 1.0));
                float v5 = floor(clamp(abs(coord2.y) / (0.5 + lineWidth), 0.0, 1.0));
                float v6 = floor(clamp(abs(coord3.y) / (0.5 + lineWidth), 0.0, 1.0));
                float v7 = floor(clamp(abs(coord3.y) / lineWidth, 0.0, 1.0));
                float vrt = and(floor(coord3.x) + 1.0, floor(coord3.y) + 1.0);
                float vlt = and(-floor(coord3.x), floor(coord3.y) + 1.0);
                float vrd = and(floor(coord3.x) + 1.0, -floor(coord3.y));
                float vld = and(-floor(coord3.x), -floor(coord3.y));
                // 对每个 最小拼接块 的不同六边形的部分，设置不同的随机参数
                fixed2 r1 = and(v7, and(vlt, or(or(v4, v5), v6))) * (center + fixed2(0.5 / hexagonNum) * fixed2(-1.0, 1.0));
                fixed2 r2 = and(v7, and(vrt, or(or(v4, v5), v6))) * (center + fixed2(0.5 / hexagonNum) * fixed2(1.0, 1.0));
                fixed2 r3 = and(v7, and(vld, or(or(v4, v5), v6))) * (center + fixed2(0.5 / hexagonNum) * fixed2(-1.0, -1.0));
                fixed2 r4 = and(v7, and(vrd, or(or(v4, v5), v6))) * (center + fixed2(0.5 / hexagonNum) * fixed2(1.0, -1.0));
                fixed2 r5 = not(or(or(v1, v2), v3)) * (center);
                fixed2 v = r1 + r2 + r3 + r4 + r5;
                return v;
            }
            
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 t1 = tex2D(_MainTex, i.uv);
                fixed4 t2 = tex2D(_SecondTex, i.uv);
                
                
                // 最小拼接块的数量
                fixed2 hexagonNum = fixed2(30.0, 30.0);
                fixed2 honeyCombPos = generateHoneyComb(hexagonNum, i.uv, 0.0);
                fixed2 axisPos = honeyCombPos;
                float w = 0.5;
                float rotateTheta = clamp(-1.0 / w * i.uv.x + _Ratio * (w + 1.0) / w + ceil(_Ratio - 0.001) * random(axisPos), 0.0, 1.0) * PI;
                
                fixed2 texCoordAfterTransform = transform(i.uv, rotateTheta, axisPos, hexagonNum);
                fixed4 texColor1 = tex2D(_MainTex, texCoordAfterTransform);
                texCoordAfterTransform.x = 2.0 * axisPos.x - texCoordAfterTransform.x;
                fixed4 texColor2 = tex2D(_SecondTex, texCoordAfterTransform);
                
                fixed4 resColor = fixed4(_Ratio, 0.0, 0.0, 1.0);
                if (rotateTheta <= 0.5 * PI)
                {
                    float rotateThetaNor = rotateTheta * 2.0 / PI;
                    resColor = texColor1 * (1.0 - rotateThetaNor * 0.5);
                }
                else if(rotateTheta > 0.5 * PI)
                {
                    float rotateThetaNor = (rotateTheta - 0.5 * PI) * 2.0 / PI;
                    resColor = texColor2 * (0.5 + rotateThetaNor * 0.5);
                }
                
                return resColor ;
            }
            ENDCG
            
        }
    }
}
