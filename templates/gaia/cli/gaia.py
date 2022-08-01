import spacy
import sys
nlp = spacy.load("en_core_web_sm")

def doit(filepath="./clean.txt"): 
    with open(filepath, 'r') as file: 
        text = file.read() 
        doc=nlp(text) 
        print([tok.text for tok in doc if not tok.is_stop]) 
        #return doc

if __name__ == "__main__":
    doit(sys.stdin)
