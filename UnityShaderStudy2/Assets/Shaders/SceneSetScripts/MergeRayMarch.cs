// **********************************************************************
// - FileName:          MergeRayMarch.cs
// - Author:            #AuthorName#
// - CreateTime:        #CreateTime#
// - Email:             #AuthorEmail#
// - Modifier:
// - Description:
// - (C)Copyright  
// - All Rights Reserved.
// **********************************************************************

using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MergeRayMarch : MonoBehaviour {
    public Material material;
    public Texture2D _NoiseTex;
    public Vector4 _LoopNum;

    private Camera myCamera;
    public  Camera camera {
        get {
            if (myCamera == null) {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

    private Transform myCameraTransform;
    public Transform cameraTransform {
        get {
            if (myCameraTransform == null) {
                myCameraTransform = camera.transform;
            }
            return myCameraTransform;
        }
    }

    private void Start()
    {
        if (material == null || material.shader == null || !material.shader.isSupported) {
            this.enabled = false;
            return;
        }
    }

    private void OnEnable()
    {
        //获取相机深度纹理;
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    [ImageEffectOpaque] 
    //默认情况下，OnRenderImage函数在所有不透明和透明Pass执行完毕后调用，对场景中所有游戏对象产生影响;
    //ImageEffectOpaque 特性 在不透明Pass执行完毕后立即执行 OnRenderImage 函数;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            SetRay();
            material.SetTexture("_NoiseTex", _NoiseTex);
            material.SetVector("_LoopNum", _LoopNum);
            Graphics.Blit(src, dest, material);
        }
        else {
            Graphics.Blit(src,dest);
        }
    }

    void SetRay() {
        Matrix4x4 frustumCorners = Matrix4x4.identity;

        float fov = camera.fieldOfView;
        float near = camera.nearClipPlane;
        float aspect = camera.aspect;

        float halfHeight = near * Mathf.Tan(fov*0.5f*Mathf.Deg2Rad);
        Vector3 toRight = camera.transform.right * halfHeight * aspect;
        Vector3 toTop = camera.transform.up * halfHeight;

        Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
        float scale = topLeft.magnitude / near;

        topLeft.Normalize();
        topLeft *= scale;

        Vector3 topRight = cameraTransform.forward * near + toTop + toRight;
        topRight.Normalize();
        topRight *= scale;

        Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
        bottomLeft.Normalize();
        bottomLeft *= scale;

        Vector3 bottomRight = cameraTransform.forward * near - toTop + toRight;
        bottomRight.Normalize();
        bottomRight *= scale;

        frustumCorners.SetRow(0,bottomLeft);
        frustumCorners.SetRow(1,bottomRight);
        frustumCorners.SetRow(2,topRight);
        frustumCorners.SetRow(3,topLeft);

        material.SetMatrix("_FrustumCornorsRay",frustumCorners);
        material.SetMatrix("_UnityMatVP",frustumCorners);
    }
}