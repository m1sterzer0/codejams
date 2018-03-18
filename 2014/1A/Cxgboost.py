import sys
import fileinput
import numpy as np 
import matplotlib
import matplotlib.pyplot as plt
import random
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from xgboost import XGBClassifier
import pickle
random.seed(1)
np.random.seed(1)

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

class MyInput(object) :
    def __init__(self,default_file="A.in") :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input(default_file)]
        #if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.short")]
        else                   : self.lines = [x for x in fileinput.input()]
        self.lineno = 0
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    def getfloatline(self,n=-1) :
        ans = tuple(float(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getfloatline'%(n,len(ans)))
        return ans
    def getstringline(self,n=-1) :
        ans = tuple(self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getstringline'%(n,len(ans)))
        return ans
    def getbinline(self,n=-1) :
        ans = tuple(int(x,2) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getbinline'%(n,len(ans)))
        return ans

def genMetrics(deck,N) :
    displacement = [ deck[i]-i for i in range(N) ]
    (h1,_) = np.histogram(displacement, range=(-1000,1000), bins=2)
    (h2,_) = np.histogram(displacement, range=(-1000,1000), bins=4)
    (h3,_) = np.histogram(displacement, range=(-1000,1000), bins=8)
    (h4,_) = np.histogram(displacement, range=(-1000,1000), bins=16)
    (h5,_) = np.histogram(displacement, range=(-1000,1000), bins=32)
    feature = np.concatenate((h1,h2,h3,h4,h5))
    return feature        

def makeDataset(N,samples) :
    numGoodSamples,numBadSamples = samples//2,samples-samples//2
    goodIndicator = np.ones((numGoodSamples,1))
    badIndicator  = np.zeros((numBadSamples,1))
    indicator = np.concatenate((goodIndicator,badIndicator),0)
    goodArr = np.array(makeGoodDeckArr(N,numGoodSamples))
    badArr = np.array(makeBadDeckArr(N,numBadSamples))
    decks = np.concatenate((goodArr,badArr),0)
    features = np.apply_along_axis(genMetrics, 1, decks, N=N)
    return np.concatenate((indicator,features),1)

def makeGoodDeckArr(N,trials) :
    arr = [[x for x in range(N)] for y in range(trials)]
    for t in range(trials) :
        a = arr[t]
        for k in range(N) :
            p = random.randint(k,N-1)
            a[k],a[p] = a[p],a[k]
    return arr

def makeBadDeckArr(N,trials) :
    arr = [[x for x in range(N)] for y in range(trials)]
    for t in range(trials) :
        a = arr[t]
        for k in range(N) :
            p = random.randint(0,N-1)
            a[k],a[p] = a[p],a[k]
    return arr

if __name__ == "__main__" :
    #doTrain,doTest,doInput = True,True,False
    doTrain,doTest,doInput = False,False,True
    if (doTrain) :
        print("Generating Training Data...")
        trainDataset = makeDataset(1000,20000)
        X_train = trainDataset[:,1:]
        Y_train = trainDataset[:,0]
        print("Training Model...")
        model = XGBClassifier()
        model.fit(X_train,Y_train)
        print("Saving Model...")
        pickle.dump(model, open("C.xgbmodel","wb"))
    if (doTest) :
        print("Generating Testing Data...")
        testDataset = makeDataset(1000,20000)
        X_test = testDataset[:,1:]
        Y_test = testDataset[:,0]
        print("Loading Model...")
        model = pickle.load(open("C.xgbmodel","rb"))
        print("Creating Predictions...")
        y_pred = model.predict(X_test)
        predictions = [round(x) for x in y_pred]
        accuracy = accuracy_score(Y_test,predictions)
        print ("Accuracy: %.2f%%" % (accuracy*100))
    if (doInput) :
        myin = MyInput("C.test.in")
        (t,) = myin.getintline()
        model = pickle.load(open("C.xgbmodel","rb"))
        for tt in range(t) :
            (n,) = myin.getintline(1)
            deck = myin.getintline(n)
            adeck = np.array([deck])
            features = np.apply_along_axis(genMetrics, 1, adeck, N=n)
            y_pred = model.predict(features)
            myType = "GOOD" if y_pred[0] > 0.5 else "BAD" 
            print("Case #%d: %s" % (tt+1,myType))        




