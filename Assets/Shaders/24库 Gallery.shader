Shader "Jack Shaders/24库 Gallery"
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
            
            //#define u_width 2000
            //#define u_height 1125
            #define PI 3.1415926
            fixed2 transform(fixed2 texCoord, fixed2 xyOffset, float zOffset, fixed2 scaleCenter, float theta, fixed2 thetaCenter)
            {
                fixed2 res = texCoord;
                // xy 位移
                res = res - xyOffset;
                // z 位移，体现为缩放
                res = res - scaleCenter;
                res = res * (1.0 + zOffset);
                res = res + scaleCenter;
                // 旋转
                res = res - thetaCenter;
                res.x = res.x / (cos(theta) + 0.0001);
                res.y = res.y / (1.0 - res.x * sin(theta));
                res.x = res.x / (1.0 - res.x * sin(theta));
                res = res + thetaCenter;
                return res;
            }
            
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed2 screenCenter = 0.5;
                fixed4 texColor1 = 0.0;
                fixed4 texColor2 = 0.0;
                float intensityOffset = 0.0;
                fixed2 thetaCenter = fixed2(1.0, 0.5);
                float t1 = 0.4;
                float t2 = 0.7;
                if (u_ratio < t1)
                {
                    float R1 = clamp((u_ratio - 0.0) / (t1 - 0.0), 0.0, 1.0);
                    float zOffset1 = 0.0;
                    fixed2 screenCenter1 = 0.5;
                    fixed2 xyOffset1 = fixed2(0.0, 0.0);
                    float theta1 = -R1 * PI * 0.06;
                    fixed2 coord1 = transform(texCoord, xyOffset1, zOffset1, screenCenter1, theta1, thetaCenter);
                    if(coord1.y < 0.0)
                    {
                        // 倒影的实现
                        coord1.y = -coord1.y - 0.01;
                        intensityOffset = -coord1.y * 5.0 - 0.5;
                    }
                    if (UVRange0_1(coord1) > 0.1)
                        texColor1 = tex2D(_MainTex, coord1) * (1.0 + intensityOffset);
                }
                if(u_ratio >= t1 && u_ratio < t2)
                {
                    float R2 = clamp((u_ratio - t1) / (t2 - t1), 0.0, 1.0);
                    float zOffset1 = 0.2 * R2;
                    fixed2 xyOffset1 = fixed2(-0.8 * R2, 0.0);
                    float theta1 = -PI * 0.06;
                    fixed2 coord1 = transform(texCoord, xyOffset1, zOffset1, screenCenter, theta1, thetaCenter);
                    if(coord1.y < 0.0)
                    {
                        coord1.y = -coord1.y - 0.01;
                        intensityOffset = -coord1.y * 5.0 - 0.5;
                    }
                    if(UVRange0_1(coord1) > 0.1)
                        texColor1 = tex2D(_MainTex, coord1) * (1.0 + intensityOffset);
                    
                    float zOffset2 = -0.2 * (1.0 - R2);
                    fixed2 xyOffset2 = fixed2(1.0 * (1.0 - R2), 0.0);
                    float theta2 = -PI * 0.06;
                    fixed2 coord2 = transform(texCoord, xyOffset2, zOffset2, screenCenter, theta2, thetaCenter);
                    if(coord2.y < 0.0)
                    {
                        coord2.y = -coord2.y - 0.01;
                        intensityOffset = -coord2.y * 5.0 - 0.5;
                    }
                    if(UVRange0_1(coord2) > 0.1)
                        texColor2 = tex2D(_SecondTex, coord2) * (1.0 + intensityOffset);
                }
                if(u_ratio > t2)
                {
                    float R3 = clamp((u_ratio - t2) / (1.0 - t2), 0.0, 1.0);
                    float zOffset1 = 0.2 * (1.0 - R3);
                    fixed2 xyOffset1 = fixed2(-0.8 - 0.25 * R3, 0.0);
                    float theta1 = -PI * 0.06 * (1.0 - R3);
                    fixed2 coord1 = transform(texCoord, xyOffset1, zOffset1, screenCenter, theta1, thetaCenter);
                    if(coord1.y < 0.0)
                    {
                        coord1.y = -coord1.y - 0.01;
                        intensityOffset = -coord1.y * 5.0 - 0.5;
                    }
                    if(UVRange0_1(coord1) > 0.1)
                        texColor1 = tex2D(_MainTex, coord1) * (1.0 + intensityOffset);
                    
                    float zOffset2 = 0.0;
                    fixed2 xyOffset2 = fixed2(0.0, 0.0);
                    float theta2 = -PI * 0.06 * (1.0 - R3);
                    fixed2 coord2 = transform(texCoord, xyOffset2, zOffset2, screenCenter, theta2, thetaCenter);
                    if(coord2.y < 0.0)
                    {
                        coord2.y = -coord2.y - 0.01;
                        intensityOffset = -coord2.y * 5.0 - 0.5;
                    }
                    if(UVRange0_1(coord2) > 0.1)
                        texColor2 = tex2D(_SecondTex, coord2) * (1.0 + intensityOffset);
                }
                return texColor1 + texColor2 ;
            }
            ENDCG
            
        }
    }
}
