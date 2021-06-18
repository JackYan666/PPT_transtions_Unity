
// 图片混合方法；线性插值
fixed4 mix(fixed4 a, fixed4 b, float alpha)
{
    fixed4 res = 0;
    res = a * (1 - alpha) + b * alpha;
    return res;
}

//判断UV是否在0-1范围内：0不在范围内；1在范围内
fixed UVRange0_1(fixed2 bud2)
{
    if (bud2.x < - 0.001)
        return 0.0;
    if(bud2.x > 1.001)
        return 0.0;
    if(bud2.y < - 0.001)
        return 0.0;
    if(bud2.y > 1.001)
        return 0.0;
    return 1;
}

