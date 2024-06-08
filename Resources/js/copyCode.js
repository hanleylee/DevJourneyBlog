function copyCode(button, event) {
  event.preventDefault();
  const codeBlock = button.parentNode.nextElementSibling.textContent; // 获取代码内容
  navigator.clipboard.writeText(codeBlock).then(() => {
    // 显示 "Copied"
    button.querySelector('.copied-text').style.display = 'flex';

    // 3秒后恢复
    setTimeout(() => {
      button.querySelector('.copied-text').style.display = 'none';
    }, 3000);
  });
}
