// **********************************************************************
// - FileName:          CameraControl.cs
// - Author:              #AuthorName#
// - CreateTime:       #CreateTime#
// - Email:                 #AuthorEmail#
// - Modifier:
// - Description:
// - (C)Copyright  
// - All Rights Reserved.
// **********************************************************************

using UnityEngine;
using System.Collections;

public class CameraControl : MonoBehaviour {

    public float moveSpeed = 10f;
    public float rotateSpeed = 1f;

    //旋转变量;
    private float m_deltaY = 0.0f;
    private float m_deltaX = 0.0f;

    //缩放变量;
    private float m_distance = 10f;
    private float m_mSpeed = 5f;

    private Camera camera;

    // Use this for initialization
    void Start () {
        camera = GetComponent<Camera>();
        if (camera == null) {
            enabled = false;
            return;
        }
    }

    // Update is called once per frame
    void Update () {
        //鼠标右键控制旋转;
        if (Input.GetMouseButton(1)) {
            m_deltaX += Input.GetAxis("Mouse X") * m_mSpeed * rotateSpeed;
            m_deltaY -= Input.GetAxis("Mouse Y") * m_mSpeed * rotateSpeed;
            m_deltaX = ClampAngle(m_deltaX,-360,360);
            m_deltaY = ClampAngle(m_deltaY,-60,60);
            camera.transform.rotation = Quaternion.Euler(m_deltaY,m_deltaX,0);
        }
        //滚轮控制缩放;
        if(Input.GetAxis("Mouse ScrollWheel")!=0){
            m_distance = Input.GetAxis("Mouse ScrollWheel") * 10f;
            camera.transform.localPosition = camera.transform.localPosition + camera.transform.forward * m_distance * moveSpeed;
        }
        //中间自由平移;
        if (Input.GetMouseButton(2)) {
            transform.Translate(Vector3.left*Input.GetAxis("Mouse X"));
            transform.Translate(Vector3.down*Input.GetAxis("Mouse Y"));
        }
        //相机复位;
        if (Input.GetKey(KeyCode.Space)) {
            m_distance = 10.0f;
            camera.transform.localPosition = new Vector3(0,m_distance,0);
        }
    }

    float ClampAngle(float angle, float minAngle, float maxAngle) {
        if (angle >= 360)
            angle -= 360;
        if (angle <= -360)
            angle += 360;
        return Mathf.Clamp(angle,minAngle,maxAngle);
    }
}