// Global Chart.js font settings
Chart.defaults.font.family = "'Arial', 'Helvetica', sans-serif"; // clean font
Chart.defaults.font.style = 'normal'; // remove italic
Chart.defaults.color = "#333"; // dark grey

document.addEventListener("DOMContentLoaded", function() {
    if (!chartData) return;

    const containerWidth = document.getElementById('calorieChart').parentNode.offsetWidth;
    const baseFont = containerWidth < 400 ? 14 : 16;
    const titleFont = containerWidth < 400 ? 16 : 18;
    const legendFont = containerWidth < 400 ? 14 : 16;

    // ======== Calorie Chart ========
    const ctx = document.getElementById('calorieChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: chartData.labels,
            datasets: [
                { label: 'Actual', data: chartData.actual, borderColor: 'blue', fill: false, tension: 0.1 },
                { label: 'Target', data: chartData.target, borderColor: 'purple', borderDash: [5,5], fill: false, tension: 0.1 },
                { label: 'Projected', data: chartData.projected, borderColor: 'green', borderDash: [5,2], fill: false, tension: 0.1 }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: { position: 'top', labels: { font: { size: legendFont } } },
                title: { display: true, text: 'Calories Today', font: { size: titleFont } }
            },
            scales: {
                x: { title: { display: true, text: 'Time', font: { size: baseFont } }, ticks: { font: { size: baseFont } } },
                y: { title: { display: true, text: 'Cumulative Calories', font: { size: baseFont } }, ticks: { font: { size: baseFont } }, beginAtZero: true }
            }
        }
    });

    // ======== Protein Chart ========
    const proteinCtx = document.getElementById('proteinChart');
    if (proteinCtx) {
        new Chart(proteinCtx, {
            type: 'line',
            data: {
                labels: proteinData.labels,
                datasets: [
                    { label: 'Actual Protein', data: proteinData.actual, borderWidth: 3 },
                    { label: 'Target Protein', data: proteinData.target, borderWidth: 3, borderDash: [5, 5] },
                    { label: 'Projected Protein', data: proteinData.projected, borderWidth: 2 }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: { position: 'top', labels: { font: { size: legendFont } } },
                    title: { display: true, text: 'Protein Today', font: { size: titleFont } }
                },
                scales: {
                    x: { title: { display: true, text: 'Time', font: { size: baseFont } }, ticks: { font: { size: baseFont } } },
                    y: { title: { display: true, text: 'Cumulative Protein (g)', font: { size: baseFont } }, ticks: { font: { size: baseFont } }, beginAtZero: true }
                }
            }
        });
    }

    // ======== Fiber Chart ========
    const fiberCtx = document.getElementById('fiberChart');
    if (fiberCtx) {
        new Chart(fiberCtx, {
            type: 'line',
            data: {
                labels: fiberData.labels,
                datasets: [
                    { label: 'Actual Fiber', data: fiberData.actual, borderWidth: 3 },
                    { label: 'Target Fiber', data: fiberData.target, borderWidth: 3, borderDash: [5, 5] },
                    { label: 'Projected Fiber', data: fiberData.projected, borderWidth: 2 }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: { position: 'top', labels: { font: { size: legendFont } } },
                    title: { display: true, text: 'Fiber Today', font: { size: titleFont } }
                },
                scales: {
                    x: { title: { display: true, text: 'Time', font: { size: baseFont } }, ticks: { font: { size: baseFont } } },
                    y: { title: { display: true, text: 'Cumulative Fiber (g)', font: { size: baseFont } }, ticks: { font: { size: baseFont } }, beginAtZero: true }
                }
            }
        });
    }
});

