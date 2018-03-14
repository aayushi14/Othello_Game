  import React from 'react';
  import ReactDOM from 'react-dom';
  import Board from './board.jsx';

  export default function game_init(root, channel) {
    
    ReactDOM.render(<Othello channel={channel} />, root);
  }

  class Othello extends React.Component {
    constructor(props) {
      super(props);
      this.channel = props.channel;
      
      const initSquares = Array(64).fill(null);
      [initSquares[8 * 3 + 3], initSquares[8 * 3 + 4], initSquares[8 * 4 + 4], initSquares[8 * 4 + 3]] = ['X', 'O', 'X', 'O'];

      this.state = {
          squares: initSquares,
          xNumbers: 2,
          oNumbers: 2,
          xWasNext: true,
          xIsNext: true
        };

        this.channel.join()
          .receive("ok", this.gotView.bind(this))
          .receive("error", resp => { console.log("Unable to join", resp) });
        //this.channel.on("othello", state => );
      }

      gotView(view) {
        console.log(view.game.state)
        this.channel.push("othello", {"state": view.game.state})
          .receive("ok", (resp) => console.log("resp", resp))
        this.setState(view.game.state);
      }

      calculateWinner(xNumbers, oNumbers) {
        return (xNumbers + oNumbers < 64) ? null : (xNumbers === oNumbers) ? 'XO' : (xNumbers > oNumbers ? 'X' : 'O');
      }

      flipSquares(squares, position, xIsNext) {
        let modifiedBoard = null;
        // Calculate row and col of the starting position
        let [startX, startY] = [position % 8, (position - position % 8) / 8];

        if (squares[position] !== null) {
          return null;
        }

        // Iterate all directions, these numbers are the offsets in the array to reach next square
        [1, 7, 8, 9, -1, -7, -8, -9].forEach((offset) => {
        let flippedSquares = modifiedBoard ? modifiedBoard.slice() : squares.slice();
        let atleastOneMarkIsFlipped = false;
        let [lastXpos, lastYPos] = [startX, startY];

          for (let y = position + offset; y < 64; y = y + offset) {

            // Calculate the row and col of the current square
            let [xPos, yPos] = [y % 8, (y - y % 8) / 8];

            // Fix when board is breaking into a new row or col
            if (Math.abs(lastXpos - xPos) > 1 || Math.abs(lastYPos - yPos) > 1) {
              break;
            }

            // Next square was occupied with the opposite color
            if (flippedSquares[y] === (!xIsNext ? 'X' : 'O')) {
              flippedSquares[y] = xIsNext ? 'X' : 'O';
              atleastOneMarkIsFlipped = true;
              [lastXpos, lastYPos] = [xPos, yPos];
              continue;
            }
            // Next square was occupied with the same color
            else if ((flippedSquares[y] === (xIsNext ? 'X' : 'O')) && atleastOneMarkIsFlipped) {
              flippedSquares[position] = xIsNext ? 'X' : 'O';
              modifiedBoard = flippedSquares.slice();
            }
            break;
          }
        });

        return modifiedBoard;
      }

      checkAvailableMoves(color, squares) {
        return squares
        .map((value, index) => { return this.flipSquares(squares, index, color) ? index : null; })
        .filter((item) => { return item !== null; });
      }

      handleClick(i) {
        console.log(this.state);
        this.channel.push("othello", {"state": this.state})
          .receive("ok", (resp) => console.log("resp", resp))
          
        if (this.calculateWinner(this.state.xNumbers, this.state.oNumbers) || this.state.squares[i]) {
          return;
        }

        const changedSquares = this.flipSquares(this.state.squares, i, this.state.xIsNext);

        if (changedSquares === null) {
          return;
        }

        const xNumbers = changedSquares.reduce((acc, current) => { return current === 'X' ? acc + 1 : acc }, 0);
        const oNumbers = changedSquares.reduce((acc, current) => { return current === 'O' ? acc + 1 : acc }, 0);

        let shouldTurnColor = this.checkAvailableMoves(!this.state.xIsNext, changedSquares).length > 0 ? !this.state.xIsNext : this.state.xIsNext

        this.setState({
            squares: changedSquares,
            xNumbers: xNumbers,
            oNumbers: oNumbers,
            xWasNext: shouldTurnColor,
            xIsNext: shouldTurnColor
        });
      }

      resetGame() {
        this.jumpTo(0);
        this.setState({
          history: this.state.history.slice(0, 1)
        })
      }

      resetGame() {
        this.channel.push("doReset")
        .receive("ok", this.gotView.bind(this));
      }

      render() {
          //console.log(this.state);
          
      		let winner = this.calculateWinner(this.state.xNumbers, this.state.oNumbers);

      		let availableMoves = this.checkAvailableMoves(this.state.xWasNext, this.state.squares);
      		let availableMovesOpposite = this.checkAvailableMoves(!this.state.xWasNext, this.state.squares);

      		if ((availableMoves.length === 0) && (availableMovesOpposite.length === 0)) {
      			winner = this.state.xNumbers === this.state.oNumbers ? 'XO' : this.state.xNumbers > this.state.oNumbers ? 'X' : 'O';
      		}

      		let status =
      			winner ?
      				(winner === 'XO') ? 'It\'s a draw' : 'The winner is ' + (winner === 'W' ? 'White!' : 'Black!') :
      				[this.state.xIsNext ? 'Black\'s turn' : 'White\'s turn', ' with ', availableMoves.length, ' available moves.'].join('');

      		return (
      			<div className="game">
              <div className="game-left-side">
                <div className="game-board">
            			<Board squares={this.state.squares} availableMoves={availableMoves} onClick={(i) => this.handleClick(i)} />
            		</div>
            		<div></div>
              </div>
              <div className="game-info">
                <div>Black markers: {this.state.xNumbers}</div>
          			<div>White markers: {this.state.oNumbers}</div>
          			<br />
          	
          			<br />
                <div className="game-status">{status}&nbsp;{winner ? <button onClick={() => this.resetGame()}>Play again</button> : ''}</div>
              </div>
      			</div>
      		);
      }
  }
