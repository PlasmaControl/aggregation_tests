import h5py
import matplotlib.pyplot as plt
import numpy as np

f = h5py.File('data.h5', 'r')
shot="99"

fig,axes=plt.subplots(nrows=4,sharex=True)
numsteps=len(f[shot]['aDiscrete'])
dt=0.05
times=np.arange(0,numsteps*dt,dt)
points=np.linspace(0,1,10)
ind=10
axes[0].plot(times[ind:],f[shot]['aDiscrete'][ind:],c='r')
axes[0].set_ylabel('"Beam" a')
axes[0].set_ylim((0,1))
axes[1].plot(times[ind:],f[shot]['bDiscrete'][ind:],c='k')
axes[1].set_ylabel('"Beam" b')
axes[1].set_ylim((0,1))
axes[2].contourf(times[ind:-1],points,f[shot]['deposition'][ind:].T)
axes[2].axhline(0.8,c='r',linestyle='--',alpha=0.5)
axes[2].axhline(0.2,c='k',linestyle='--',alpha=0.5)
axes[2].set_ylabel('Deposition')
axes[3].contourf(times[ind:-1],points,f[shot]['T'][ind:].T)
axes[3].set_ylabel('Temp')

axes[-1].set_xlabel('Time')

fig.suptitle(f'"Shot" {shot}')

plt.show()
