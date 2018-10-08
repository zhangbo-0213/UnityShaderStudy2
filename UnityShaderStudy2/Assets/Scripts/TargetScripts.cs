// **********************************************************************
// - FileName:          TargetScripts.cs
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

public class TargetScripts : MonoBehaviour {

    public GameObject Target;
    void Update()
    {
        GetComponent<Renderer>().material.SetVector("_TargetPosition", Target.transform.position);
    }
}