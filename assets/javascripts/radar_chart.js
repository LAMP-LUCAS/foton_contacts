window.renderRadarChart = function(canvasId, chartData, chartLabels, chartOptions = {}) {
  const ctx = document.getElementById(canvasId).getContext("2d");
  new Chart(ctx, {
    type: 'radar',
    data: {
      labels: chartLabels,
      datasets: chartData
    },
    options: {
      responsive: true,
      scales: {
        r: {
          suggestedMin: 0,
          suggestedMax: 100
        }
      },
      ...chartOptions
    }
  });
};
