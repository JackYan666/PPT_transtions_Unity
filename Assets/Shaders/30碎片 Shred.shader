Shader "Jack Shaders/30碎片 Shred"
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
            
            #define u_width 2000
            #define u_height 1125
            #define PI 3.1415926
            fixed2 transform(fixed2 texCoord, fixed2 xyOffset, float zOffset, fixed2 scaleCenter, float xTheta, fixed2 xThetaCenter, float yTheta, fixed2 yThetaCenter, float zTheta, fixed2 zThetaCenter)
            {
                fixed2 res = texCoord;
                float projectPar = 0.8;
                // 绕 x 轴旋转
                res = res - xThetaCenter;
                res.y = res.y / cos(xTheta);
                res.y = res.y / (1.0 - projectPar * res.y * sin(xTheta));
                res.x = res.x / (1.0 - projectPar * res.y * sin(xTheta));
                res = res + xThetaCenter;
                // 绕 y 轴旋转
                res = res - yThetaCenter;
                res.x = res.x / cos(yTheta);
                res.y = res.y / (1.0 - projectPar * res.x * sin(yTheta));
                res.x = res.x / (1.0 - projectPar * res.x * sin(yTheta));
                res = res + yThetaCenter;
                // 绕 z 轴旋转
                res = res - zThetaCenter;
                res = res * fixed2(u_width, u_height);
                res = fixed2(dot(fixed2(cos(zTheta), sin(zTheta)), res), dot(fixed2(-sin(zTheta), cos(zTheta)), res));
                res = res / fixed2(u_width, u_height);
                res = res + zThetaCenter;
                // z 方向位移
                res = res - scaleCenter;
                res = res * (1.0 + zOffset);
                res = res + scaleCenter;
                // xy 方向位移
                res = res - xyOffset;
                return res;
            }
            float random(fixed2 st)
            {
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            float random(float inV)
            {
                return random(fixed2(inV, inV));
            }
            float generateFrag(fixed2 texCoord)
            {
                fixed2 coord = texCoord;
                float num = 12.0;
                float v = ceil(frac(coord.x * num) * 2.0 - 1.0);
                float floorV = floor(coord.x * num * 2.0);
                coord.x = coord.x + random(floorV) / num * 0.5;
                if (coord.y < random(floor(coord.x * num * 2.0)))
                    v = 1.0 - v;
                if(texCoord.x < 0.0 || texCoord.x > 1.0 || texCoord.y < 0.0 || texCoord.y > 1.0)
                    v = 0.0;
                return v;
            }
            
            fixed4 textureSelect(fixed2 coord)
            {
                fixed4 resColor = 0.0;
                if(u_ratio < 0.5)
                    resColor = tex2D(_MainTex, coord);
                else
                resColor = tex2D(_SecondTex, coord);
                return resColor;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed4 resCol = 0.0;
                
                fixed2 scaleCenter = (0.5);
                fixed2 xThetaCenter = (0.5);
                fixed2 yThetaCenter = (0.5);
                fixed2 zThetaCenter = (0.5);
                fixed4 resColor1 = (0.0);
                fixed4 resColor2 = (0.0);
                fixed2 res1 = texCoord;
                fixed2 res2 = texCoord;
                
                float zOffset = 0.0;
                fixed2 xyOffset = (0.0);
                float xTheta = -PI * 0.05;
                float yTheta = PI * 0.1;
                float zTheta = 0.0;
                
                float t1 = 0.3;
                float t2 = 0.7;// 保证 t1 + t2 = 1.0，且都在 0-1 之间
                
                if (u_ratio < t1 || u_ratio >= t2)
                {
                    float R1 = (-abs(u_ratio - 0.5) + 0.5) / t1;
                    xTheta = -PI * 0.05 * R1;
                    yTheta = PI * 0.1 * R1;
                    {
                        
                        zOffset = (0.4) * R1;
                        res1 = transform(texCoord, xyOffset, zOffset, scaleCenter, xTheta, xThetaCenter, yTheta, yThetaCenter, zTheta, zThetaCenter);
                        float mask = generateFrag(res1);
                        if(UVRange0_1(res1) > 0.1)
                            resColor1 = textureSelect(res1) * mask;
                    }
                    {
                        
                        zOffset = (0.6) * R1;
                        res2 = transform(texCoord, xyOffset, zOffset, scaleCenter, xTheta, xThetaCenter, yTheta, yThetaCenter, zTheta, zThetaCenter);
                        float mask = 1.0 - generateFrag(res2);
                        if(UVRange0_1(res2) > 0.1)
                            resColor2 = textureSelect(res2) * mask;
                    }
                    
                    resCol = mix(resColor2, resColor1, resColor1.a);
                }
                if(u_ratio >= t1 && u_ratio < t2)
                {
                    float R2 = 1.0 - abs((u_ratio - t1) / (t2 - t1) * 2.0 - 1.0);
                    zOffset = 0.4 - 1.5 * R2;
                    xyOffset = fixed2(0.7, 0.2) * R2;
                    res1 = transform(texCoord, xyOffset, zOffset, scaleCenter, xTheta, xThetaCenter, yTheta, yThetaCenter, zTheta, zThetaCenter);
                    float mask = generateFrag(res1);
                    
                    if(UVRange0_1(res1) > 0.1)
                        resColor1 = textureSelect(res1) * mask;
                    zOffset = 0.6 + 5.0 * R2;
                    xyOffset = fixed2(-1.5, -0.2) * R2;
                    res2 = transform(texCoord, xyOffset, zOffset, scaleCenter, xTheta, xThetaCenter, yTheta, yThetaCenter, zTheta, zThetaCenter);
                    mask = 1.0 - generateFrag(res2);
                    if(UVRange0_1(res2) > 0.1)
                        resColor2 = textureSelect(res2) * mask;
                    resCol = mix(resColor2, resColor1, resColor1.a);
                }
                
                return resCol;
            }
            ENDCG
            
        }
    }
}
