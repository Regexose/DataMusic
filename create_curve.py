import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import numpy as np
 # referenz: https://www.youtube.com/watch?v=1H-SdMuJXTk
def func(x, a, b):
    return a * np.exp(b*x)

# create datapoints
xData = np.arange(50)
yDAta = np.random.uniform(low=20.0, high=73.3, size=(50,))

plt.plot(xData, yData, 'bo', label='experimental-data')

# perfomrm curve Fit
popt, pcov = curve_fit(func, xData, yData)
+# values for fitted function
xFit = np.arange(0.0, 5.0, 0.01)
plt.plot(xFot, func(xFit, *popt), 'r', label='fit params: a=%5.3f, b=%5.3f' % tuple(popt))
plt.show

