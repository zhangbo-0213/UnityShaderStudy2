// **********************************************************************
// - FileName:          SetCameraDepthMode.cs
// - Author:              #AuthorName#
// - CreateTime:       #CreateTime#
// - Email:                 #AuthorEmail#
// - Modifier:
// - Dscription:
// - (C)Copyright  
// - All Rights Reserved.
// **********************************************************************

using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class SetCameraDepthMode : MonoBehaviour {
    private Camera mainCamera;
    public Camera Camera {
        get {
            if (mainCamera == null) {
                mainCamera = GetComponent<Camera>();
            }
            return mainCamera;
        }
    }

    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
    }
}