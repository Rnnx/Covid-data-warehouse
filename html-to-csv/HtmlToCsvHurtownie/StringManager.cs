using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;

namespace HtmlToCsvHurtownie
{
    public class StringManager
    {
        private bool isStarted = false;
        private List<int> listOfIndexes = new List<int>();


        public string DeleteComa(string data)
        {
            var word = new List<char>(data);

            listOfIndexes.Clear();

            for(int i=0; i<data.Length; i++)
            {
                if (data[i] == '"' && isStarted == false)
                {
                    isStarted = true;
                    listOfIndexes.Add(i);
                }
                else if(data[i]==',' && isStarted == true)
                {
                    listOfIndexes.Add(i);
                }
                else if(data[i]=='"' && isStarted == true)
                {
                    isStarted = false;
                    listOfIndexes.Add(i);
                }
            }

            int j = 0;

            listOfIndexes.Sort();

            if (listOfIndexes.Count > 0)
            {
                for(int index=0; index<listOfIndexes.Count; index++)
                {
                    word.RemoveAt(listOfIndexes.ElementAt(index) - j);
                    j++;
                }
            }           
            StringBuilder stringBuilder = new StringBuilder();
            foreach(char item in word)
            {
                stringBuilder.Append(item);
            }
            string finalWord = stringBuilder.ToString();
            return finalWord;
        }
    }
}
