// **********************************************************************
// - FileName:          ActionController.cs
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

public class ActionController : MonoBehaviour {
    public Animator animator;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1)) {
            animator.SetTrigger("1");
        }
        if (Input.GetKeyDown(KeyCode.Alpha2)) {
            animator.SetTrigger("2");
        }
        if (Input.GetKeyDown(KeyCode.Alpha3)) {
            animator.SetTrigger("3");
        }
    }
}