﻿Shader "Jack Shaders/17蜂巢 HoneyComb"
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
            // 此变换函数对 图片 进行缩放和旋转
            fixed2 transform(fixed2 texcoord, fixed2 ceter, fixed2 scaleRatio, float theta)
            {
                fixed2 res = texcoord - ceter;// 图片从缩放中心点移动到原点
                // 旋转前转到真实的像素坐标，不然不能保证角度仍然是九十度
                res = res * fixed2(u_width, u_height);
                // 执行旋转
                res = fixed2(dot(fixed2(cos(theta), sin(theta)), res), dot(fixed2(-sin(theta), cos(theta)), res));
                res = res / scaleRatio;// 执行缩放
                res = res / fixed2(u_width, u_height);
                res = res + ceter;// 图片从原点移动回缩放中心点
                return res;
            }
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
                st = floor(st * 1000.0) / 1000.0 + fixed2(0.001,0.001); // 保留三位小数，防止由于精度不够，出现误差
                return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
            }
            float generateHoneyComb(fixed2 hexagonNum, fixed2 texCoord)
            {
                // 确定每个 最小拼接块 的中心
                fixed2 center = floor(texCoord * hexagonNum) * (1.0 / hexagonNum) + 0.5 / hexagonNum;
                fixed2 coord = texCoord - center;
                // 为了画出一个六边形，分别执行 0度、60度、120度 旋转
                fixed2 coord1 = transform(coord, PI / 3.0, hexagonNum);
                fixed2 coord2 = transform(coord, -PI / 3.0, hexagonNum);
                fixed2 coord3 = transform(coord, 0.0, hexagonNum);
                // 蜂窝边缘的宽度
                float lineWidth = 0.05;
                // 分别求出最小拼接块内的各个组块的表达式，通过布尔运算进行组合
                float k1 = 1.0 / (0.5 - lineWidth);
                float v1 = floor(clamp(abs(coord1.y) * k1, 0.0, 1.0));
                float v2 = floor(clamp(abs(coord2.y) * k1, 0.0, 1.0));
                float v3 = floor(clamp(abs(coord3.y) * k1, 0.0, 1.0));
                float k2 = 1.0 / (0.5 + lineWidth);
                float v4 = floor(clamp(abs(coord1.y) * k2, 0.0, 1.0));
                float v5 = floor(clamp(abs(coord2.y) * k2, 0.0, 1.0));
                float v6 = floor(clamp(abs(coord3.y) * k2, 0.0, 1.0));
                float k3 = 1.0 / lineWidth;
                float v7 = floor(clamp(abs(coord3.y) * k3, 0.0, 1.0));
                float vrt = and(floor(coord3.x) + 1.0, floor(coord3.y) + 1.0);
                float vlt = and(-floor(coord3.x), floor(coord3.y) + 1.0);
                float vrd = and(floor(coord3.x) + 1.0, -floor(coord3.y));
                float vld = and(-floor(coord3.x), -floor(coord3.y));
                // 对每个 最小拼接块 的不同六边形的部分，设置不同的随机参数
                float r1 = and(v7, and(vlt, or(or(v4, v5), v6))) * random(center + fixed2(0.5 / hexagonNum) * fixed2(-1.0, 1.0));
                float r2 = and(v7, and(vrt, or(or(v4, v5), v6))) * random(center + fixed2(0.5 / hexagonNum) * fixed2(1.0, 1.0));
                float r3 = and(v7, and(vld, or(or(v4, v5), v6))) * random(center + fixed2(0.5 / hexagonNum) * fixed2(-1.0, -1.0));
                float r4 = and(v7, and(vrd, or(or(v4, v5), v6))) * random(center + fixed2(0.5 / hexagonNum) * fixed2(1.0, -1.0));
                float r5 = not(or(or(v1, v2), v3)) * random(center);
                float v = r1 + r2 + r3 + r4 + r5;
                return v;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                // fixed4 t1 = tex2D(_MainTex, i.uv);
                // fixed4 t2 = tex2D(_SecondTex, i.uv);
                
                fixed u_ratio=_Ratio;
                
                // 设置第一张图的 旋转角度、缩放因子，随后进行变换
                float theta1 = PI / 3.0 * u_ratio;
                fixed2 scaleRatio1 = (fixed2)(1.0 + 7.0 * u_ratio);
                fixed2 coord1 = transform(i.uv, fixed2(0.5, 0.5), scaleRatio1, theta1);
                fixed4 texColor1 = tex2D(_MainTex, coord1);
                
                // 设置第二张图的 旋转角度、缩放因子，随后进行变换
                float theta2 = PI / 3.0 * (u_ratio - 1.0);
                fixed2 scaleRatio2 = (fixed2)(1.0 - 0.9 * (1.0 - u_ratio));
                fixed2 coord2 = transform(i.uv, fixed2(0.5, 0.5), scaleRatio2, theta2);
                fixed4 texColor2 = tex2D(_SecondTex, coord2);
                
                // 最小拼接块的数量
                fixed2 hexagonNum = fixed2(7.0, 7.0);
                float v1 = generateHoneyComb(hexagonNum, coord1);
                if (u_ratio > v1)
                    v1 = 0.0;
                float v2 = 1.0 - generateHoneyComb(hexagonNum, coord2);
                if(u_ratio > v2)
                    v2 = 0.0;
                
                float w = 0.3;
                // 由 蜂窝状的形状 和 开始以及结束的擦除 共同确定透明度
                float R1 = clamp(-1.0 / w * coord1.x + u_ratio * 10.0 * (w + 1.0) / w, 0.0, 1.0);
                float R2 = clamp(-1.0 / w * coord2.x + (w + 1.0) / w + (u_ratio - 0.9) * 10.0 * ( - (w + 1.0) / w), 0.0, 1.0);
                
                float mixPar1 = (1.0 - ceil(v1 - 0.0001)) * R1;
                float mixPar2 = ceil(v2 - 0.0001) * R2;
                
                texColor2 = mix(texColor2, (fixed4)(0.0), mixPar2);
                // FragColor = mix(texColor1, texColor2, mixPar1);
                return mix(texColor1, texColor2, mixPar1) ;
            }
            ENDCG
            
        }
    }
}
