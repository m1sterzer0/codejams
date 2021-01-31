# Can you win at least X fraction of the time?
def CanWin(X):
  A = []
  last_G_values = 0

  # C < G, not enough coins for a reroll.
  for C in range(0, G):
    A.append(avg_win_prob_top[N] - X)
    last_G_values += A[C]

  # C >= G, enough coins for a reroll.
  for C in range(G, R * G + 1):
    A.append(-1e100)
    for K in range(1, N + 1):
      p = (N - K) / N  # Probability of rerolling.
      p_reroll = p / (1 - p) * last_G_values
      p_not_reroll = avg_win_prob_top[K] - X
      A[C] = max(A[C], p_reroll + p_not_reroll)

    if A[C] >= 0: return True
    last_G_values += A[C] - A[C - G]

  return False


last = 0
for tc in range(int(input())):
  [N, R, G] = map(int, input().split())
  win_prob = map(float, input().split())
  win_prob = sorted(win_prob, reverse=True)

  avg_win_prob_top = [0]
  for topK in range(1, N + 1):
    avg_win_prob_top.append(sum(win_prob[0:topK]) / topK)

  lo = 0
  hi = 1
  for i in range(60):
    mid = (lo + hi) / 2
    if CanWin(mid):
      lo = mid
    else:
      hi = mid

  if tc % 2 == 0 :
    last = lo
  else :
    print("Case #%d-#%d: %.15f" % (tc + 1,tc, abs(lo-last)))    

