# QKP_Rollout
## Introduction
This repository presents a rollout method for constrained dynamic programming, applied to the 0-1 Quadratic Knapsack Problem (QKP):

$$ 
\begin{alignat}{1}
\\text{maximize }\ & \sum_{i=1}^{n}\sum_{j=1}^{n}p_{ij}x_{i}x_{j}, \\\\
\\text{subject to }\ & \sum_{i=1}^{n}w_{i}x_{i} \leq C, \\\\
& \mathbf{x}\in \\{0,1\\}^{n} =: \mathbb{B}^{n}.
\end{alignat}
$$

Using the well-known exact McCormick relaxation of 0-1 QKP 

$$
\begin{alignat}{1}
\\text{maximize }\ & \sum_{i=1}^{n}\sum_{j=1}^{n}p_{ij}u_{ij}, \\\\
\\text{subject to }\ & u_{ij} \geq x_{j}+x_{i}-1,\text{ for all $i\in [n]$, $j\in [n]$}, \\\\
& u_{ij} \leq x_{i},\text{ for all $i\in [n]$, $j\in [n]$},\\\\
& u_{ij} \leq x_{j},\text{ for all $i\in [n]$, $j\in [n]$},\\\\
& \sum_{i=1}^{n}w_{i}x_{i}\leq C, \\\\
& \\mathbf{x} \in  \mathbb{B}^{n},\ \\mathbf{u}\in\mathbb{R}_{\geq0}^{n\times n}
\end{alignat}
$$

at ... 

## Data
Data for this project is generated using the standard scheme for testing algorithms designed for solving the 0-1 QKP. Particularly, for the profits associated with pairing $i$ with $j$, 

$$p_{ij}\sim \begin{cases}0 & \\text{with probability } 1-\Delta,  \\\\ \\text{Uniform}\\{1,\ldots,100\\} & \\text{with probability } \Delta.\end{cases}$$

where is $$\Delta$$ referred to as the *density* for the problem. The density, $$\Delta$$, is particularly important for determining the difficulty of the problem instance in consideration.
For larger values of $$\Delta$$, the impact of its effects is observed through the objective function, in which a larger $$\Delta$$ may yield an objective function with greatly many more terms. Consequently,
this entails that there more likely will be many interactions that will need to be considered when optimizing, therein resulting in a significantly more challenging problem. On the other
hand, the remaining data $$w_{i}\sim \\text{Uniform}\\{1,\ldots,n\\}$$ for each $$i$$, whereas $$C\sim\\{n,\ldots,\sum_{i=1}^{n}w_{i}\\}$$.
