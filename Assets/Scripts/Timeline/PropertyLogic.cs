using ExpressionParser;
using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using UnityEngine;
using UnityEngine.Events;

public class PropertyLogic : MonoBehaviour
{
    [SerializeField] string m_propertyName;
    public string propertyName { get { return m_propertyName; } }
    [SerializeField] string m_expression;
    [SerializeField] List<ExpressionParameter> m_parameters;

    ExpressionDelegate m_expressionDelegate;

    [Serializable]
    class ExpressionParameter
    {
        [HideInInspector] public GameObject m_hostObject;

        [SerializeField] string m_parameterName;
        public string parameterName { get { return m_parameterName; } }

        [ValueDropdown("getComponentsNames")]
        [SerializeField] string m_componentType;

        [ValueDropdown("getPropertiesNames")]
        [SerializeField] string m_valueName;
        
        [LabelText("Axis")]
        [ShowIf("isVector2")]
        [SerializeField] Vector2Axis m_v2Axis;
        [LabelText("Axis")]
        [ShowIf("isVector3")]
        [SerializeField] Vector3Axis m_v3Axis;

        enum Vector2Axis
        {
            X, Y
        }

        enum Vector3Axis
        {
            X, Y, Z
        }

        List<string> getComponentsNames()
        {
            List<string> names = new List<string>();
            if (m_hostObject == null)
                return names;

            foreach (var c in m_hostObject.GetComponents<Component>())
                if (c != null)
                    names.Add(c.GetType().Name);

            return names;
        }

        List<string> getPropertiesNames()
        {
            List<string> names = new List<string>();
            if (m_hostObject == null)
                return names;

            var comp = m_hostObject.GetComponent(m_componentType);
            if (comp == null)
                return new List<string> { "None" };

            var type = comp.GetType();
            var fields = type.GetFields();
            foreach (var f in fields)
            {
                if (evaluateValidityProperty(f))
                    names.Add("Field " + f.Name + " (" + f.GetType().Name + ")");
            }

            var properties = type.GetProperties();
            foreach (var p in properties)
            {
                if (!p.CanRead)
                    continue;
                if (evaluateValidityProperty(p))
                    names.Add("Property " + p.Name + " (" + p.GetGetMethod().ReturnType.Name + ")");
            }

            var methods = type.GetMethods();
            foreach (var m in methods)
            {
                if (m.GetParameters().Length > 0)
                    continue;
                if (m.Name.StartsWith("get_"))
                    continue;
                var returnType = m.ReturnType;
                if(evaluateValidityProperty(returnType))
                    names.Add("Method " + m.Name + " (" + returnType.Name + ")");

            }


            if (names.Count == 0)
                names.Add("None");

            return names;
        }

        bool evaluateValidityProperty(FieldInfo f)
        {
            return evaluateValidityProperty(f.GetType());
        }

        bool evaluateValidityProperty(PropertyInfo f)
        {
            return evaluateValidityProperty(f.GetGetMethod().ReturnType);
        }

        bool evaluateValidityProperty(Type t)
        {
            if (t.IsEnum)
                return true;
            if (t == typeof(float))
                return true;
            if (t == typeof(double))
                return true;
            if (t == typeof(int))
                return true;
            if (t == typeof(Vector3))
                return true;
            if (t == typeof(Vector2))
                return true;
            if (t == typeof(bool))
                return true;
            return false;
        }

        bool isVector2()
        {
            var type = getSelectedType();
            if (type == null)
                return false;
            return type == typeof(Vector2);
        }

        bool isVector3()
        {
            var type = getSelectedType();
            if (type == null)
                return false;
            return type == typeof(Vector3);
        }

        Type getSelectedType()
        {
            if (m_valueName == null)
                return null;

            var propertyNameSplited = m_valueName.Split(' ');
            if (propertyNameSplited.Length < 2)
                return null;

            if (m_hostObject == null)
                return null;
            var comp = m_hostObject.GetComponent(m_componentType);
            if (comp == null)
                return null;

            var compType = comp.GetType();
            if (compType == null)
                return null;
            if (propertyNameSplited[0].Trim().ToLower() == "field")
            {
                var f = compType.GetField(propertyNameSplited[1]);
                if (f == null)
                    return null;
                return f.GetType();
            }
            if (propertyNameSplited[0].Trim().ToLower() == "property")
            {
                var p = compType.GetProperty(propertyNameSplited[1]);
                if (p == null)
                    return null;
                var m = p.GetGetMethod();
                if (m == null)
                    return null;
                return m.ReturnType;
            }
            if (propertyNameSplited[0].Trim().ToLower() == "method")
            {
                var m = compType.GetMethod(propertyNameSplited[1]);
                if (m == null)
                    return null;
                return m.ReturnType;
            }
            return null;
        }

        public double get(GameObject obj)
        {
            var propertyNameSplited = m_valueName.Split(' ');
            if (propertyNameSplited.Length < 2)
            {
                Debug.LogError("Null or innaccessible property");
                return 0;
            }

            if (obj == null)
            {
                Debug.LogError("The supported object is null");
                return 0;
            }
            var comp = obj.GetComponent(m_componentType);
            if (comp == null)
            {
                Debug.LogError("Unable to find the component");
                return 0;
            }

            var compType = comp.GetType();
            if (propertyNameSplited[0].Trim().ToLower() == "field")
                return objectToDouble(compType.GetField(propertyNameSplited[1]).GetValue(comp));
            if (propertyNameSplited[0].Trim().ToLower() == "property")
                return objectToDouble(compType.GetProperty(propertyNameSplited[1]).GetGetMethod().Invoke(comp, null));
            if (propertyNameSplited[0].Trim().ToLower() == "method")
                return objectToDouble(compType.GetMethod(propertyNameSplited[1]).Invoke(comp, null));
            Debug.LogError("Unknow component return type");
            return 0;
        }

        double objectToDouble(object obj)
        {
            var t = obj.GetType();

            if (t.IsEnum)
                return (int)obj;
            if (t == typeof(float))
                return (float)obj;
            if (t == typeof(double))
                return (double)obj;
            if (t == typeof(int))
                return (int)obj;
            if (t == typeof(Vector3))
                return ((Vector3)obj)[(int)m_v3Axis];
            if (t == typeof(Vector2))
                return ((Vector2)obj)[(int)m_v2Axis];
            if (t == typeof(bool))
                return (bool)obj ? 1 : 0;
            Debug.LogError("Unknow type");
            return 0;
        }
    }

    private void Start()
    {
        var parser = new ExpressionParser.ExpressionParser();
        Expression exp = parser.EvaluateExpression(m_expression);
        string[] parameters = new string[m_parameters.Count];
        for (int i = 0; i < m_parameters.Count; i++)
            parameters[i] = m_parameters[i].parameterName;
        m_expressionDelegate = exp.ToDelegate(parameters);
    }

    private void OnEnable()
    {
        addProperty(this);
    }

    private void OnDisable()
    {
        removeProperty(this);
    }

    public double get()
    {
        double[] parameters = new double[m_parameters.Count];
        for (int i = 0; i < m_parameters.Count; i++)
            parameters[i] = m_parameters[i].get(gameObject);
        return m_expressionDelegate(parameters);
    }
    
    public static void addProperty(PropertyLogic p)
    {
        if (!m_propertyLogics.Contains(p))
            m_propertyLogics.Add(p);
    }

    public static void removeProperty(PropertyLogic p)
    {
        m_propertyLogics.Remove(p);
    }

    public static double get(string name)
    {
        var p = m_propertyLogics.Find(x => x.name == name);
        if (p == null)
            return 0;
        return p.get();
    }

    [OnInspectorGUI]
    private void UpdateExpressionParametersObjects()
    {
        foreach (var p in m_parameters)
            p.m_hostObject = gameObject;
    }

    [Button]
    void testExpression()
    {
        var parser = new ExpressionParser.ExpressionParser();
        Expression exp = parser.EvaluateExpression(m_expression);

        foreach (var parameter in m_parameters)
            exp.Parameters[parameter.parameterName].Value = parameter.get(gameObject);

        Debug.Log(exp.Value);
    }

    static List<PropertyLogic> m_propertyLogics = new List<PropertyLogic>();
}
