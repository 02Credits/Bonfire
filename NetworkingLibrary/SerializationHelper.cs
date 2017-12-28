using System;
using System.IO;
using System.Runtime.CompilerServices;
using ProtoBuf;

namespace NetworkingLibrary
{
    public static class SerializationHelper
    {
        public static byte[] SerializeObject(object obj)
        {
            var serializeMethod = typeof (SerializationHelper).GetMethod("Serialize").MakeGenericMethod(obj.GetType());
            return (byte[])serializeMethod.Invoke(null, new [] {obj});
        }
        public static object DeserializeObject(byte[] data, Type type)
        {
            var deserializeMethod = typeof(SerializationHelper).GetMethod("Deserialize").MakeGenericMethod(type);
            return deserializeMethod.Invoke(null, new object[] { data });
        }

        public static byte[] Serialize<T>(T itemToSerialize)
        {
            byte[] returnArray;
            using (var stream = new MemoryStream())
            {
                Serializer.Serialize(stream, itemToSerialize);
                returnArray = stream.ToArray();
            }
            return returnArray;
        }

        public static T Deserialize<T>(byte[] data)
        {
            using (var stream = new MemoryStream(data))
            {
                return Serializer.Deserialize<T>(stream);
            }
        }
        public static T DeserializeFileOrValue<T>(string fileName, T otherwise)
        {
            Console.WriteLine("Attempting deserialization of " + fileName);
            if (File.Exists(fileName))
            {
                using (var stream = File.OpenRead(fileName))
                {
                    try
                    {
                        var obj = Serializer.Deserialize<T>(stream);
                        Console.WriteLine("Success!");
                        return obj;
                    }
                    catch
                    {
                        Console.WriteLine("Source file corrupt... Returning default.");
                        return otherwise;
                    }
                }
            }
            else
            {
                Console.WriteLine("File doesnt exist. Returning default.");
                return otherwise;
            }
        }

        public static void SerializeToFile<T>(string fileName, T obj)
        {
            Console.WriteLine("Saving to " + fileName);
            var path = Path.GetDirectoryName(fileName);
            if (!Directory.Exists(path) && !String.IsNullOrWhiteSpace(path))
                Directory.CreateDirectory(path);
            using (var stream = File.OpenWrite(fileName))
            {
                Serializer.Serialize(stream, obj);
                Console.WriteLine("    Finished");
            }
        }
    }
}
