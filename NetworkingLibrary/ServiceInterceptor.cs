using Castle.DynamicProxy;
using Lidgren.Network;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public class ServiceInterceptor : IInterceptor
    {
        string serviceName;
        ServiceManager manager;
        ServiceConnection connection;

        public ServiceInterceptor(ServiceManager manager, string serviceName, ServiceConnection connection)
        {
            this.serviceName = serviceName;
            this.manager = manager;
            this.connection = connection;
        }

        public void Intercept(IInvocation invocation)
        {
            var method = typeof(ServiceManager).GetMethod("SendCommand");
            MethodInfo generic;
            if (!invocation.Method.ReturnType.ToString().StartsWith("System.Threading.Tasks.Task"))
            {
                throw new ArgumentException("All service methods must be async and return a task.");
            }

            if (invocation.Method.ReturnType.GenericTypeArguments.Any())
            {
                generic = method.MakeGenericMethod(invocation.Method.ReturnType.GenericTypeArguments[0]);
            }
            else
            {
                generic = method.MakeGenericMethod(typeof(bool));
            }

            var response = generic.Invoke(manager, new object[] { serviceName, connection, invocation.Method.Name, invocation.Arguments.ToList() });

            invocation.ReturnValue = response;
        }
    }
}