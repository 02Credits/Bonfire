using Lidgren.Network;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public class DynamicPublishedServiceExecutor : PublishedServiceExecutor
    {
        Dictionary<string, Func<NetIncomingMessage, byte[]>> parsers = new Dictionary<string, Func<NetIncomingMessage, byte[]>>();
        public override Dictionary<string, Func<NetIncomingMessage, byte[]>> Parsers
        {
            get { return parsers; }
        }

        public DynamicPublishedServiceExecutor(ServiceManager manager, Service serviceObject)
            : base(manager, serviceObject)
        {
            var type = serviceObject.GetType();
            var methods = type.GetMethods();

            foreach (var method in methods)
            {
                if (method.IsPublic)
                {
                    var reflectedParameters = method.GetParameters();
                    var methodReference = method;
                    parsers[method.Name] = (msg) =>
                    {
                        var parameterList = new List<object>();
                        foreach (var parameter in reflectedParameters)
                        {
                            var dataLength = msg.ReadInt32();
                            var data = msg.ReadBytes(dataLength);
                            parameterList.Add(SerializationHelper.DeserializeObject(data, parameter.ParameterType));
                        }

                        var returnValue = methodReference.Invoke(serviceObject, parameterList.ToArray());

                        if (returnValue == null)
                        {
                            return new byte[] { };
                        }
                        else
                        {
                            return SerializationHelper.SerializeObject(returnValue);
                        }
                    };
                }
            }
        }


    }
}
